import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/Pages/to_visualizer_bridge.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_remove_selector.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:food_delivery_app/cubit/add_remove_counter_cubit.dart';
import 'package:gap/gap.dart';

class ProductItem extends StatefulWidget {
  static const double imageSize = 80;
  static const double rowHeight = 150;

  final Product product;
  final bool hasPermission;
  final VoidCallback? onDeleteRequest;
  final bool canModifyCart;
  final int? fixedCount;

  const ProductItem({
    super.key,
    required this.product,
    this.hasPermission = false,
    this.onDeleteRequest,
    this.canModifyCart = true,
    this.fixedCount
  }) : assert(!hasPermission || onDeleteRequest!=null), 
      assert(canModifyCart || fixedCount != null);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  late CartBloc cartBloc;
  late StreamSubscription cartSubscription;

  late AddRemoveCounterCubit addRemoveCounterCubit;

  final double internalPadding = 10;
  final double imageWidth = 100;

  ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  void initState() {
    if(widget.canModifyCart)
    {
      cartBloc = BlocProvider.of<CartBloc>(context);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductItem.rowHeight,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        clipBehavior: Clip.hardEdge,
        color: Theme.of(context).dialogBackgroundColor,
        child: FdaLoading(
          loadingNotifier: loading,
          dynamicText: ValueNotifier(""),
          child: Padding(
            padding: EdgeInsets.all(internalPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(                  
                  width: imageWidth,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          defaultBorderRadius - internalPadding / 2)),
                  child: ZoomableImage(
                    provider: FdaCachedNetworkImage(
                      url: FdaServerCommunication.getImageUrl(
                        widget.product.imageName!
                      )
                    ).getImageProvider(),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${widget.product.price}€",
                            textAlign: TextAlign.end,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          const Gap(20),
                          if(!widget.canModifyCart)
                          Text("x${widget.fixedCount.toString()}")
                        ],
                      ),
                      if(widget.canModifyCart)
                      Expanded(
                        child: Row(
                          children: [
                            if(widget.hasPermission)
                            GestureDetector(
                              onTap: widget.onDeleteRequest,
                              child: Row(
                                children: [
                                  Text(
                                    "Elimina",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.red
                                    ),
                                  ),
                                  const Icon(
                                      Icons.delete_forever_rounded,
                                      color: Colors.red,
                                    ),
                                ],
                              ),
                            ),                            
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: AddRemove<CartBloc, CartState>(
                                  bloc: cartBloc,
                                  listener: (context, state) => loading.value = false,
                                  stateToCount: (state) => state.cart[widget.product] ?? 0,
                                  onAddPressed: () {
                                    loading.value = true;
                                    cartBloc.add(
                                      AddProductToCart(widget.product)
                                    );
                                  },
                                  onRemovePressed: () {
                                    loading.value = true;
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
      ),
    );
  }
}