import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';

class CategoryInfo extends StatefulWidget{
  final ProductsCategory category;
  final int? fixedCount;
  final void Function(int value) onCountChanged;

  const CategoryInfo({
    super.key,
    required this.category,
    required this.onCountChanged,
    this.fixedCount
  });

  @override
  State<CategoryInfo> createState() => _CategoryInfoState();
}

class _CategoryInfoState extends State<CategoryInfo> {
  CartBloc? cartBloc;
  StreamSubscription? cartSubscription;
  int count = 0;

  void countCategoryProductsInCart() {
    count = widget.category.products.fold(
        0,
        (previousValue, product) =>
            previousValue + (cartBloc?.state.products[product] ?? 0));

    widget.onCountChanged.call(count);
  }

  @override
  void initState() {
    if(widget.fixedCount == null)
    {
      cartBloc = BlocProvider.of<CartBloc>(context);
      cartSubscription = cartBloc?.stream.listen((event) {
        if ((event is CartProductAdded &&
            widget.category.products.contains(event.addedProduct)) ||

            event is CartProductRemoved &&
            widget.category.products.contains(event.removedProduct)) {
          countCategoryProductsInCart();
        }
      });      
      countCategoryProductsInCart();
    }
    else {
      count = widget.fixedCount!;
    }
    super.initState();
  }

  @override
  void dispose() {
    cartSubscription?.cancel();
    super.dispose();
  }

  Widget counterWidget()
  {
    if(count > 0)
    {
      return Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text("$count")
        ),
      );
    }
    else{
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.category.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text("${widget.category.products.length} prodotti"),
            ],
          ),
        ),
        if(widget.fixedCount==null)
        BlocBuilder<CartBloc, CartState>(
          bloc: cartBloc,
          buildWhen: (previous, current) => 
            (current is CartProductAdded &&
            widget.category.products.contains(current.addedProduct))
            || (current is CartProductRemoved &&
            widget.category.products.contains(current.removedProduct)),
          builder: (context, state) {
            return counterWidget();
          },
        ),
        if(widget.fixedCount != null)
        counterWidget()
      ],
    );
  }
}