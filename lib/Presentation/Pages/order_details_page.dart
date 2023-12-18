import 'package:flutter/material.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Order/order_info_header.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Product/product_item.dart';
import 'package:food_delivery_app/Presentation/Pages/Templates/dialog_page_template.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/Utilities/compute_total.dart';

/// Questa pagina permette di visualizzare tutti i dettagli di un ordine
/// rappresentato dalla calsse [Order] visualizzandone anche i prodotti
/// che questo contiene rappresentati dalla classe [Product].
/// 
/// Inoltre, è dotata di una modalità di gestione che permette di gestire
/// lo stato di un ordine rappresentato dall'enum [OrderStatus].

class OrderDetailsPage extends StatelessWidget
{
  final bool hasPermission;
  final Order order;
  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.hasPermission
  });

  @override
  Widget build(BuildContext context) {
    ScrollController parentScrollController = ScrollController();
    List<MapEntry<Product, int>> content = order.content.entries.toList();
    ValueNotifier<bool> loading = ValueNotifier(false);
    return DialogPageTemplate(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            controller: parentScrollController,
            child: NotificationListener<OverscrollNotification>(
              onNotification: (notification) => 
              scrollParentOnChildOverscroll(notification, parentScrollController),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500
                ),
                child: Hero(
                  tag: order.id,
                  child: Material(
                    elevation: defaultElevation,
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
                            padding: const EdgeInsets.all(20.0),
                            child: OrderInfoHeader(
                              order: order,
                              hasPermission: hasPermission,
                              loading: loading,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: (order.content.length < 3? 
                                order.content.length : 2.5) * ProductItem.rowHeight + 
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
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
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
                          ),
                        ],
                      ),
                    ),
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