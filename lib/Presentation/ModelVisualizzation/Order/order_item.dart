import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/Pages/order_details_page.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';

class OrderItem extends StatelessWidget
{
  final bool hasPermission;
  final Order order;
  const OrderItem({
    super.key,
    required this.order,
    required this.hasPermission
  });

  @override
  Widget build(BuildContext context) {

    var finalV = order.content.entries.length != 1? "i":"o";

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
        tag: order,
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) => this,
        child: Material(
          elevation: 10,
          color: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadius)
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Ordine per ${order.deliveryInfo.intercom}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    Text("${order.deliveryInfo.city}, ${order.deliveryInfo.address}, ${order.deliveryInfo.houseNumber}"),
                    Icon(
                      Icons.location_on_rounded, 
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ],
                ),
                Row(
                  children: [
                     Text(
                      "Data: ${order.dateTime.day}-${order.dateTime.month}-${order.dateTime.year} "
                      "${order.dateTime.hour.toString().padLeft(2,'0')}:"
                      "${order.dateTime.minute.toString().padLeft(2,'0')}"
                    ),     
                    Icon(
                      Icons.access_time_outlined, 
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ],
                ),
                      
                Text("${order.content.entries.length} prodott$finalV ordinat$finalV"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.status.visualize,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}

