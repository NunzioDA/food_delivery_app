import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';

/// Questo widget rappresenta un header raffigurante informazioni base
/// riguardanti un [Order] tra cui le informazioni di consegna [DeliveryInfo]
/// Permette inoltre di interagire con [OrderBloc] andando a modificare lo stato 
/// dell'ordines.
class OrderInfoHeader extends StatefulWidget
{
  final Order order;
  final bool hasPermission;
  final bool static;
  final ValueNotifier<bool>? loading;
  const OrderInfoHeader({
    super.key,
    required this.order,
    this.hasPermission = false,
    this.static = false,
    this.loading
  });

  @override
  State<OrderInfoHeader> createState() => _OrderInfoHeaderState();
}

class _OrderInfoHeaderState extends State<OrderInfoHeader> {
  
  late OrderBloc orderBloc;
  late Order order;

  @override
  void initState() {
    order = widget.order;
    if(!widget.static){
      orderBloc = BlocProvider.of<OrderBloc>(context);
    }
    super.initState();
  }

  int productsCount()
  {
    return widget.order.content.entries.fold(0, 
      (previousValue, element) => previousValue + element.value
    );
  }

  Widget statusText(OrderStatus status)
  {
    return Text(
      status.visualize,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: status == OrderStatus.placed? 
         Colors.amber:
          status == OrderStatus.left? 
          Colors.green: 
          status == OrderStatus.delivered?
          Colors.black:
          Colors.red
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var finalV = widget.order.content.entries.length != 1? "i":"o";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ordine ${widget.order.id}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if(!widget.static)
            BlocConsumer<OrderBloc, OrderState>(
              bloc: orderBloc,
              buildWhen: (previous, current) => (current is OrderUpdated && widget.hasPermission)
              || current is OrdersFetched,
              listener: (context, state) {
                widget.loading?.value = false;
                if(state is OrdersFetched)
                {
                  order = state.orders.firstWhere((element) => element == widget.order);
                }
                else if(state is OrderError && state.event is OrderUpdated)
                {
                  DialogShower.showAlertDialog(
                    context,
                    "Attenzione", 
                    "C'è stato un problema nell'aggiornamento dell'ordine"
                  );
                }
              },
              builder: (context, state) {
                return widget.hasPermission?
                DropdownButton(
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                  alignment: Alignment.centerRight,
                  value: order.status,                  
                  items: OrderStatus.values.map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: statusText(e)
                    )
                  ).toList(), 
                  onChanged: (value) {
                    widget.loading?.value = true;
                    orderBloc.add(UpdateOrder(order, value!));
                  },
                ):
                statusText(order.status);
              },
            ),
            if(widget.static)       
            statusText(widget.order.status)
          ],
        ),
        Text(
          widget.order.deliveryInfo.intercom,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Row(
          children: [
            Text("${widget.order.deliveryInfo.city}, ${widget.order.deliveryInfo.address}, ${widget.order.deliveryInfo.houseNumber}"),
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
              "Data: ${widget.order.dateTime.day}-${widget.order.dateTime.month}-${widget.order.dateTime.year} "
              "${widget.order.dateTime.hour.toString().padLeft(2,'0')}:"
              "${widget.order.dateTime.minute.toString().padLeft(2,'0')}"
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