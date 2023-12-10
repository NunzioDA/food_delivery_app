import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Product/product_item.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';
import 'package:gap/gap.dart';

class CartContent extends StatelessWidget {

  final VoidCallback onCompleteOrderRequest;
  const CartContent({
    super.key,
    required this.onCompleteOrderRequest
  });

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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 1,
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 10,
                        children: productsInCart
                            .map((product) => ProductItem(
                                  product: product,
                                ))
                            .toList(),
                      ),
                    ),                    
                    SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: onCompleteOrderRequest, 
                        child: const Text("Completa ordine")
                      ),
                    )
                  ],
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


