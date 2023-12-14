import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Order/order_item.dart';
import 'package:food_delivery_app/Presentation/Pages/order_details_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';

/// Questa pagina permette di visualizzare tutti gli ordini 
/// effettuati mostrandone le informazioni tramite [OrderItem]
/// e successivamente visualizzarne i dettagli tramite [OrderDetailsPage]

class MyOrdersPage extends StatefulWidget
{
  const MyOrdersPage({
    super.key,
  });

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {

  late OrderBloc orderBloc;
  @override
  void initState() {
    orderBloc = BlocProvider.of<OrderBloc>(context);
    orderBloc.add(FetchMyOrders());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OrderBloc, OrderState>(
          bloc: orderBloc,
          listener: (context, state) {
            if(state is OrderError && state.event is FetchMyOrders)
            {
              DialogShower.showAlertDialog(
                context, 
                "Attenzione", 
                "Si è verificato un problema nel caricamento dei tuoi ordini.\nRiprova."
              );
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
                  hasPermission: false,
                ),
              ),
            );
          },
        )
      ),
    );
  }
}

