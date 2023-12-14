import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';

class OrderInfoHeader extends StatefulWidget
{
  final Order order;
  final bool hasPermission;
  final ValueNotifier<bool>? loading;
  const OrderInfoHeader({
    super.key,
    required this.order,
    this.hasPermission = false,
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
    if(widget.hasPermission){
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
        color: status != OrderStatus.delivered && 
        status != OrderStatus.canceled? 
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
            if(widget.hasPermission)
            BlocConsumer<OrderBloc, OrderState>(
              bloc: orderBloc,
              buildWhen: (previous, current) => current is OrderUpdated,
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
                return DropdownButton(
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
                );
              },
            ),
            if(!widget.hasPermission)
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