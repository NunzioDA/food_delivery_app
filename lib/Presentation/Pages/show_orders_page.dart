import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Order/order_item.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';


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

  late OrderBloc orderBloc;
  Timer? updateTimer;

  // Questa variabile permette di evitara l'accavallarsi di dialoghi di errore
  // evitando inoltre la petulanza causata dal ripetersi di messaggi di errore
  // a causa del timer attivo.
  // Quando il dialogo viene mostrato viene impostato ad un numero negativo
  // così diminuendo non sarà mai uguale a 0. Tornando a 10 solo dopo aver chiuso il dialogo.
  // Da quel momento bisogna che l'errore avvenga 10 volte prima che venga mostrato nuovamente.
  // Oppure quando il fetching avviene correttamente la variabile viene azzerata.
  int errorShowCountDown = 0;

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
  }

  @override
  void initState() {
    orderBloc = BlocProvider.of<OrderBloc>(context);
    
    updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      orderBloc.add(fetchEvent);
    });

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
    orderBloc.add(fetchEvent);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OrderBloc, OrderState>(
          bloc: orderBloc,
          listener: (context, state) {
            if(state is OrderError && 
            (state.event is FetchReceivedOrders ||
              state.event is FetchMyOrders
            ) &&
            errorShowCountDown == 0)
            {              
              errorShowCountDown = -1;
              DialogShower.showAlertDialog(
                context, 
                "Attenzione", 
                "Si è verificato un problema nel caricamento degli ordini.\nRiprova."
              ).then((value) => errorShowCountDown = 10);              
            }
            else if(state is OrderError && 
            state.event is FetchReceivedOrders){
              errorShowCountDown--;
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

            return Column(
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 20, 
                      right: 20, 
                      top: 10,
                      bottom: 20
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) => Padding(
                      padding: (index<orders.length -1)? const EdgeInsets.only(bottom: 20) : EdgeInsets.zero,
                      child: OrderItem(
                        order: orders[index],
                        hasPermission: widget.hasPermission,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        )
      ),
    );
  }
}

