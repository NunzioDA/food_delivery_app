import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Order/order_item.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dynamic_grid_view.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/palette.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';
import 'package:food_delivery_app/cubit/connectivity_cubit.dart';
import 'package:gap/gap.dart';


/// Questa pagina permette di visualizzare tutti gli ordini 
/// effettuati mostrandone le informazioni tramite [OrderItem].
/// 
/// E' inoltre dotata di un timer di aggiornamento periodico che permette 
/// all'utente di essere sempre aggiornato sui nuovi ordini in arrivo nel caso di
/// utente con permessi potendoli gestire in tempo reale; o per essere sempre aggiornato
/// sullo stato dei propri ordini.

class ShowOrdersPage extends StatefulWidget
{
  final bool hasPermission;
  const ShowOrdersPage({
    super.key,
    required this.hasPermission,
  });

  @override
  State<ShowOrdersPage> createState() => _ShowOrdersPageState();
}

class _ShowOrdersPageState extends State<ShowOrdersPage> {

  late ConnectivityCubit connectivityCubit;
  late OrderBloc orderBloc;
  Timer? updateTimer;
  bool canMakeRequest = true;

  // Questa variabile permette di evitara l'accavallarsi di dialoghi di errore
  // evitando inoltre la petulanza causata dal ripetersi di messaggi di errore
  // a causa del timer attivo.
  // Quando il dialogo viene mostrato viene impostato ad un numero negativo
  // così diminuendo non sarà mai uguale a 0. Tornando a 10 solo dopo aver chiuso il dialogo.
  // Da quel momento bisogna che l'errore avvenga 10 volte prima che venga mostrato nuovamente.
  // Oppure quando il fetching avviene correttamente la variabile viene azzerata.
  int errorShowCountDown = 0;

  ValueNotifier<bool> loading = ValueNotifier(true);

  late OrderEvent fetchEvent;
  List<Order> orders = [];

  void updateFetchEvent()
  {
    if(widget.hasPermission){
      fetchEvent = FetchReceivedOrders();
    }
    else {
      fetchEvent = FetchMyOrders();
    }
    
    if(connectivityCubit.state is Connected)
    {
      loading.value = true;
      orderBloc.add(fetchEvent);
    }
    else{
      canMakeRequest = true;
    }

    if(orderBloc.state is OrdersFetched)
    {
      orders = (orderBloc.state as OrdersFetched).orders;
    }

    if(!(updateTimer?.isActive ?? false))
    {
      initTimer();
    }
  }

  void initTimer()
  {
    updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(canMakeRequest && connectivityCubit.state is Connected)
      {
        canMakeRequest = false;
        orderBloc.add(fetchEvent);
      }
    });
  }

  @override
  void initState() {
    orderBloc = BlocProvider.of<OrderBloc>(context);
    connectivityCubit = BlocProvider.of<ConnectivityCubit>(context);    

    super.initState();
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  bool anyOrderChanged(List<Order> previous, List<Order> current)
  {
    for(int i =0; i<previous.length; i++)
    {
      if(previous[i]!=current[i] || previous[i].status != current[i].status)
      {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    updateFetchEvent();
    
    return FdaLoading(
      loadingNotifier: loading,
      dynamicText: ValueNotifier("Solo qualche secondo..."),
      child: Scaffold(
        body: BlocConsumer<OrderBloc, OrderState>(
          bloc: orderBloc,
          listener: (context, state) {
            loading.value = false;
            canMakeRequest = true;
            if(state is OrderError && 
            (state.event is FetchReceivedOrders ||
              state.event is FetchMyOrders))
            {
              if(errorShowCountDown == 0)
              {              
                errorShowCountDown = -1;

                String connectivityMsg="";
                if(connectivityCubit.state is! Connected)
                {
                  connectivityMsg = "Stato connessione:\n${connectivityCubit.stateToMessage()}";
                }

                DialogShower.showAlertDialog(
                  context, 
                  "Attenzione", 
                  "Si è verificato un problema nel caricamento degli ordini.\n"
                  "$connectivityMsg"
                ).then((value) => errorShowCountDown = 10);              
              }
              else {
                errorShowCountDown--;
              }
            }           
            else if(state is OrdersFetched)
            {
              orders = state.orders;
              errorShowCountDown = 0;
            }
          },
          buildWhen: (previous, current) => (current is OrdersFetched
          && (previous is! OrdersFetched ||
          previous.orders.length != current.orders.length ||
          anyOrderChanged(previous.orders, current.orders))),
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20, 
                      right: 20, 
                      top: 20,
                      bottom: 10
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          !widget.hasPermission? "I tuoi ordini" : "Ordini ricevuti",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          !widget.hasPermission? 
                          "Qui puoi visualizzare lo stato di tutti gli ordini da"
                          " te effettuati." : 
                          "Qui puoi visualizzare tutti gli ordini dei tuoi clienti"
                          " gestendone lo stato." ,
                        ),
                      ],
                    ),
                  ),
                  if(orders.isNotEmpty)
                  DynamicGridView(
                    targetItemWidth: 300,
                    spacing: 20,
                    runSpacing: 20,
                    padding: const EdgeInsets.all(20),
                    children: orders.map((e) => 
                      OrderItem(
                        order: e,
                        hasPermission: widget.hasPermission,
                      ),
                    ).toList()
                  ),
                  if(orders.isEmpty)
                  const Gap(50),
                  if(orders.isEmpty)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset("assets/empty.png"),
                          const Gap(25),
                          AutoSizeText(
                            "Non ci sono ancora ordini",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

