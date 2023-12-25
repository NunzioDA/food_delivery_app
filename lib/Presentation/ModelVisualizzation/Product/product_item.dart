import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/add_remove_selector.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/cached_image.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/loading.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:gap/gap.dart';

import '../../UIUtilities/zoomable_image.dart';

/// Questo widget può essere usato in layout a scorrimento
/// per la visualizzazione delle informazioni riguardanti
/// una collezione di [Product].
/// 
/// Permette inoltre tramite il widget [AddRemove] di aggiungere e 
/// rimuovere il prodotto rappresentato al carrello il cui stato 
/// è contenuto in [CartBloc].

class ProductItem extends StatefulWidget {
  static const double imageSize = 80;
  static const double rowHeight = 120;

  final Product product;
  final bool hasPermission;
  final VoidCallback? onDeleteRequest;
  final bool canModifyCart;
  final int? fixedCount;
  final double elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ProductItem({
    super.key,
    required this.product,
    this.hasPermission = false,
    this.onDeleteRequest,
    this.canModifyCart = true,
    this.fixedCount,
    this.elevation = 5,
    this.backgroundColor,
    this.borderRadius
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
        borderRadius: widget.borderRadius?? BorderRadius.circular(defaultBorderRadius),
        clipBehavior: Clip.hardEdge,
        color: widget.backgroundColor ?? Theme.of(context).dialogBackgroundColor,
        child: FdaLoading(
          loadingNotifier: loading,
          dynamicText: ValueNotifier(""),
          child: Padding(
            padding: EdgeInsets.all(internalPadding),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(                     
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            defaultBorderRadius - internalPadding / 2)),
                    child: ZoomableImage(
                      image: FdaCachedNetworkImage(
                        url: FdaServerCommunication.getImageUrl(
                          widget.product.imageName!
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AutoSizeText(
                        widget.product.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.left,
                      ),                      
                      Expanded(
                        child: AutoSizeText(
                          widget.product.description,
                        ),
                      ),                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if(widget.canModifyCart && widget.hasPermission)
                          GestureDetector(
                            onTap: widget.onDeleteRequest,
                            child: const Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.red,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${widget.product.price}€",
                              textAlign: TextAlign.end,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),                      
                    ],
                  ),
                ),
                const Gap(10),    
                if(!widget.canModifyCart)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text("x${widget.fixedCount.toString()}")
                ),
                if(widget.canModifyCart)
                Align(
                  alignment: Alignment.centerRight,
                  child: AddRemove<CartBloc, CartState>(
                    bloc: cartBloc,
                    listener: (context, state) {
                      if(state is CartError || 
                      (state is CartProductAdded 
                      && state.addedProduct == widget.product) ||
                      (state is CartProductRemoved 
                      && state.removedProduct == widget.product))
                      {
                        loading.value = false;
                      }
                    },
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
                if(widget.canModifyCart)
                const VerticalDivider(
                  color: Colors.black,
                  width: 0,
                  thickness: 0.1,
                  endIndent: 10,
                  indent: 10,
                ),
                if(widget.canModifyCart)
                SizedBox(
                  width: 30,
                  child: InkWell(
                    onTap: (){
                      loading.value = true;                      
                      cartBloc.add(
                        RemoveProductFromCart(
                          widget.product,
                          true
                        )
                      );
                    },
                    child: const Icon(Icons.close)
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