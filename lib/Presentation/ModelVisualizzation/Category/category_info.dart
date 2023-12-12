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
  int count = 0;

  void countCategoryProductsInCart() {
    count = widget.category.products.fold(
        0,
        (previousValue, product) =>
            previousValue + (cartBloc?.state.cart[product] ?? 0));

    widget.onCountChanged.call(count);
  }

  @override
  void initState() {
    if(widget.fixedCount == null)
    {        
      cartBloc = BlocProvider.of<CartBloc>(context); 
      countCategoryProductsInCart();
    }
    else {
      count = widget.fixedCount!;
    }
    super.initState();
  }

  bool shouldReact(CartState state)
  {
    return (state is CartProductAdded &&
              widget.category.products.contains(state.addedProduct)) ||
              (state is CartProductRemoved &&
              widget.category.products.contains(state.removedProduct)) ||
              state is CartFetched;
  }

  @override
  void dispose() {
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
          child: Text(
            "$count",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white
            ),
          )
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
        BlocConsumer<CartBloc, CartState>(
          bloc: cartBloc,
          listener: (context, state) {
            if (shouldReact(state)) {
              countCategoryProductsInCart();
            }
          },
          buildWhen: (previous, current) => shouldReact(current),
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