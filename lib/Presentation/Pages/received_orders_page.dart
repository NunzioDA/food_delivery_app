import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Order/order_item.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';

class ReceivedOrdersPage extends StatefulWidget
{
  const ReceivedOrdersPage({
    super.key,
  });

  @override
  State<ReceivedOrdersPage> createState() => _ReceivedOrdersPageState();
}

class _ReceivedOrdersPageState extends State<ReceivedOrdersPage> {

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

  @override
  void initState() {
    orderBloc = BlocProvider.of<OrderBloc>(context);

    orderBloc.add(FetchReceivedOrders());
    updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      orderBloc.add(FetchReceivedOrders());
    });

    super.initState();
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OrderBloc, OrderState>(
          bloc: orderBloc,
          listener: (context, state) {
            if(state is OrderError && 
            state.event is FetchReceivedOrders &&
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
              errorShowCountDown = 0;
            }
          },
          buildWhen: (previous, current) => current is OrdersFetched,
          builder: (context, state) {

            List<Order> orders = [];

            if(state is OrdersFetched)
            {
              orders = state.orders;
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) => Padding(
                padding: (index<orders.length -1)? const EdgeInsets.only(bottom: 20) : EdgeInsets.zero,
                child: OrderItem(
                  order: orders[index],
                  hasPermission: true
                ),
              ),
            );
          },
        )
      ),
    );
  }
}

