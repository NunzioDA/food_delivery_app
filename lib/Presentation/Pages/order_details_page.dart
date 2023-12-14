import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Order/order_info_header.dart';
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
    List<MapEntry<Product, int>> content = order.content.entries.toList();

    return Scaffold(
      backgroundColor: defaultTransparentScaffoldBackgrounColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Hero(
              tag: order.id,
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
                            OrderInfoHeader(order: order),
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
                          constraints: BoxConstraints(
                            maxHeight: (order.content.length < 3? 
                              ProductItem.rowHeight : 3.0) * order.content.length + 
                              (order.content.length < 3? 20 * order.content.length + 5 : 60)
                          ),
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