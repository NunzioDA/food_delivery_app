import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Order/order_info_header.dart';
import 'package:food_delivery_app/Presentation/Pages/order_details_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';

/// Questo widget può essere usato in layout a scorrimento
/// per la visualizzazione delle informazioni riguardanti
/// una collezione di ordini definiti tramite la classe [Order].

/// Se la variabile [hasPermission] dovesse essere vera permetterebbe
/// di aprire la pagina [OrderDetailsPage] in modalità gestione permettendo
/// di gestire lo stato dell'ordine.

class OrderItem extends StatelessWidget
{
  final bool hasPermission;
  final Order order;
  const OrderItem({
    super.key,
    required this.order,
    required this.hasPermission,
  });

  @override
  Widget build(BuildContext context) {   

    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (newCont, animation, secondaryAnimation) {
            return BlocProvider.value(
              value: BlocProvider.of<OrderBloc>(context),
              child: OrderDetailsPage(
                order: order,
                hasPermission: hasPermission,
              ),
            );
          },
        ));
      },
      child: Hero(
        tag: order.id,
        flightShuttleBuilder: (
          flightContext, 
          animation, 
          flightDirection, 
          fromHeroContext, 
          toHeroContext
        ) => this,
        child: Material(
          elevation: defaultElevation,
          color: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadius)
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OrderInfoHeader(order: order, static: true,),                           
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Totale"),
                    Text(
                      "${getTotal(order.content)}€",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      )
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

