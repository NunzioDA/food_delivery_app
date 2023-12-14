import 'package:flutter/material.dart';
import 'package:food_delivery_app/Data/Model/order.dart';

class OrderInfoHeader extends StatelessWidget
{
  final Order order;
  const OrderInfoHeader({
    super.key,
    required this.order
  });

  int productsCount()
  {
    return order.content.entries.fold(0, 
      (previousValue, element) => previousValue + element.value
    );
  }

  @override
  Widget build(BuildContext context) {
    var finalV = order.content.entries.length != 1? "i":"o";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Ordine ${order.id}",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          order.deliveryInfo.intercom,
          style: Theme.of(context).textTheme.titleSmall,
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
        Text("${productsCount()} prodott$finalV ordinat$finalV"),
      ],
    );
  }

}