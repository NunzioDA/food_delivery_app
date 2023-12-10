import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:gap/gap.dart';

class CompleteOrderPage extends StatelessWidget{
  const CompleteOrderPage({super.key});

  @override
  Widget build(BuildContext context) {

    CartBloc cartBloc = BlocProvider.of<CartBloc>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,               
              children: [
                ...cartBloc.state.products.keys.map(
                  (key) => CartEntryItem(
                    product: key, 
                    count: cartBloc.state.products[key]! 
                  )
                ).toList(),
                const Gap(20),
                const Text("Inserisci un indirizzo"),
                TextFormField()
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class CartEntryItem extends StatelessWidget{
  final Product product;
  final int count;
  const CartEntryItem({
    super.key,
    required this.product,
    required this.count
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(product.name),
        Text("x$count")
      ],
    );
  }

}