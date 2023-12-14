import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Product/product_item.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dialog_manager.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';
import 'package:food_delivery_app/bloc/order_bloc.dart';
import 'package:gap/gap.dart';

class OrderDetailsPage extends StatefulWidget
{
  final bool hasPermission;
  final Order order;
  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.hasPermission
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {

  ValueNotifier<bool> loading = ValueNotifier(false);
  late OrderBloc orderBloc;
  late Order order;

  @override
  void initState() {
    order = widget.order;
    orderBloc = BlocProvider.of<OrderBloc>(context);    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var finalV = order.content.entries.length != 1? "i":"o";
    List<MapEntry<Product, int>> content = order.content.entries.toList();

    return Scaffold(
      backgroundColor: defaultTransparentScaffoldBackgrounColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Hero(
              tag: order,
              child: Material(
                elevation: 10,
                color: Theme.of(context).dialogBackgroundColor,
                shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadius)
                ),
                child: FdaLoading(
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                  loadingNotifier: loading,
                  dynamicText: ValueNotifier("Aggiorno lo stato..."),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:20, right: 20, top: 20),
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
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if(widget.hasPermission)
                                BlocConsumer<OrderBloc, OrderState>(
                                  bloc: orderBloc,
                                  buildWhen: (previous, current) => current is OrderUpdated,
                                  listener: (context, state) {
                                    loading.value = false;
                                    if(state is OrdersFetched)
                                    {
                                      order = state.orders.firstWhere((element) => element == order);
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
                                      value: order.status,
                                      items: OrderStatus.values.map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.visualize)
                                        )
                                      ).toList(), 
                                      onChanged: (value) {
                                        loading.value = true;
                                        orderBloc.add(UpdateOrder(order, value!));
                                      },
                                    );
                                  },
                                ),
                                if(!widget.hasPermission)
                                Text(
                                  order.status.visualize,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ],
                        ),
                      ),
                      const Gap(10),
                      Padding(
                        padding: const EdgeInsets.only(bottom:20.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                            itemCount: content.length,
                            itemBuilder: (context, index) {
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom:20.0),
                                child: ProductItem(
                                  product: content[index].key,
                                  canModifyCart: false,
                                  fixedCount: content[index].value,
                                ),
                              );
                            }
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}