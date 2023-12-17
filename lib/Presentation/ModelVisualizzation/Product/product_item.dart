import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/Pages/to_visualizer_bridge.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_remove_selector.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:gap/gap.dart';

/// Questo widget può essere usato in layout a scorrimento
/// per la visualizzazione delle informazioni riguardanti
/// una collezione di [Product].
/// 
/// Permette inoltre tramite il widget [AddRemove] di aggiungere e 
/// rimuovere il prodotto rappresentato al carrello il cui stato 
/// è contenuto in [CartBloc].

class ProductItem extends StatefulWidget {
  static const double imageSize = 80;
  static const double rowHeight = 150;

  final Product product;
  final bool hasPermission;
  final VoidCallback? onDeleteRequest;
  final bool canModifyCart;
  final int? fixedCount;
  final double elevation;
  final Color? backgroundColor;

  const ProductItem({
    super.key,
    required this.product,
    this.hasPermission = false,
    this.onDeleteRequest,
    this.canModifyCart = true,
    this.fixedCount,
    this.elevation = 10,
    this.backgroundColor
  }) : assert(!hasPermission || onDeleteRequest!=null), 
      assert(canModifyCart || fixedCount != null);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  late CartBloc cartBloc;
  late StreamSubscription cartSubscription;

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
        elevation: widget.elevation,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        clipBehavior: Clip.hardEdge,
        color: widget.backgroundColor ?? Theme.of(context).dialogBackgroundColor,
        child: FdaLoading(
          loadingNotifier: loading,
          dynamicText: ValueNotifier(""),
          child: Padding(
            padding: EdgeInsets.all(internalPadding),
            child: Row(
              children: [
                IntrinsicHeight(
                  child: Container(                                      
                    width: imageWidth,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            defaultBorderRadius - internalPadding / 2)),
                    child: ZoomableImage(
                      provider: CachedNetworkImageProvider(
                        FdaServerCommunication.getImageUrl(
                          widget.product.imageName!
                        )
                      ),
                    ),
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
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
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
                          if(!widget.canModifyCart)
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