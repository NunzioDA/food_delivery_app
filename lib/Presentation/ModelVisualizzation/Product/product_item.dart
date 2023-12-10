import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/Pages/to_visualizer_bridge.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_remove_selector.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/cubit/add_remove_counter_cubit.dart';
import 'package:gap/gap.dart';

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
      ),
    );
  }
}