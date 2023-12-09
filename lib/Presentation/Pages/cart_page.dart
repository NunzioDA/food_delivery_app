import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/Pages/to_visualizer_bridge.dart';
import 'package:food_delivery_app/Presentation/Utilities/add_remove_selector.dart';
import 'package:food_delivery_app/Presentation/Utilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/Utilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/cubit/add_remove_counter_cubit.dart';
import 'package:gap/gap.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Carrello",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const Gap(20),
        Expanded(
          child: BlocBuilder<CartBloc, CartState>(
            bloc: BlocProvider.of<CartBloc>(context),
            builder: (context, state) {
              List<Product> productsInCart = state.products.keys.toList();
              if (productsInCart.isNotEmpty) {
                return GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 10,
                  children: productsInCart
                      .map((product) => ProductItem(
                            product: product,
                          ))
                      .toList(),
                );
              } else {
                return Column(
                  children: [
                    Image.asset("assets/empty_list.png"),
                    Text(
                      "Il carrello è vuoto",
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class ProductItem extends StatefulWidget {
  static const double imageSize = 80;

  final Product product;
  const ProductItem({
    super.key,
    required this.product,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  late CartBloc cartBloc;
  late StreamSubscription cartSubscription;

  late AddRemoveCounterCubit addRemoveCounterCubit;

  final double internalPadding = 10;

  @override
  void initState() {
    cartBloc = BlocProvider.of<CartBloc>(context);

    // // init product count
    // int? count = cartBloc.state.products[widget.product];
    // addRemoveCounterCubit.changeCounter(count ?? 0);

    // cartSubscription = cartBloc.stream.listen((event) {
    //   if (event is CartProductAdded && event.addedProduct == widget.product) {
    //     int count = event.products[widget.product]!;
    //     addRemoveCounterCubit.changeCounter(count);
    //   } else if (event is CartProductRemoved &&
    //       event.removedProduct == widget.product) {
    //     int? count = event.products[widget.product];
    //     addRemoveCounterCubit.changeCounter(count ?? 2);
    //   }
    // });

    super.initState();
  }

  @override
  void dispose() {
    // cartSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        clipBehavior: Clip.hardEdge,
        color: Theme.of(context).dialogBackgroundColor,
        child: Padding(
          padding: EdgeInsets.all(internalPadding),
          child: Row(
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        defaultBorderRadius - internalPadding / 2)),
                child: ZoomableImage(
                  provider: FdaCachedNetworkImage(
                          url: FdaServerCommunication.getImageUrl(
                              widget.product.imageName!))
                      .getImageProvider(),
                ),
              ),
              const Gap(20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.left,
                          ),
                          Expanded(
                            child: Text(
                              widget.product.description,
                            ),
                          ),
                          Text(
                            "${widget.product.price}€",
                            textAlign: TextAlign.end,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                // Row(
                                //   children: [
                                //     Text("Rimuovi"),
                                //     GestureDetector(
                                //       onTap: (){
                                //         cartBloc.add(event)
                                //       },
                                //       child: const Icon(
                                //         Icons.delete_forever_rounded,
                                //         color: Colors.red,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: AddRemove<CartBloc, CartState>(
                                      bloc: cartBloc,
                                      stateToCount: (state) => state.products[widget.product] ?? 0,
                                      onAddPressed: () {
                                        cartBloc.add(
                                          AddProductToCart(widget.product)
                                        );
                                      },
                                      onRemovePressed: () {
                                        cartBloc.add(
                                          RemoveProductFromCart(widget.product)
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
