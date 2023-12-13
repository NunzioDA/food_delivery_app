import 'package:flutter/material.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';

class OrderItem extends StatelessWidget
{
  final Order order;
  const OrderItem({
    super.key,
    required this.order
  });

  @override
  Widget build(BuildContext context) {

    var final_v = order.content.entries.length != 1? "i":"o";

    return Material(
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
              "Ordine del ${order.dateTime.day}-${order.dateTime.month}-${order.dateTime.year}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: Theme.of(context).primaryColor,),
                Text("${order.deliveryInfo.intercom} ${order.deliveryInfo.address}, ${order.deliveryInfo.houseNumber}"),
              ],
            ),
            Text("${order.content.entries.length} prodott$final_v ordinat$final_v"),
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
            )
          ],
        ),
      ),
    );
  }

}

// ...order.content.entries.map((e) => 
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Text(e.key.name),
//                   Text("x${e.value}"),
//                 ],
//               )
//             ).toList()