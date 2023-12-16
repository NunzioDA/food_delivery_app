import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Presentation/ModelVisualizzation/Product/product_item.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/dynamic_grid_view.dart';
import 'package:food_delivery_app/bloc/cart_bloc.dart';

/// Questa classe permette di visualizzare il contenuto del carrello
/// rappresentato da [CartBloc].
/// Permetterà anche da qui, utilizzando [ProductItem], di modificare il numero
/// di prodotti contenuti nel carrello.

class CartContent extends StatelessWidget {
  const CartContent({
    super.key,
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
        Expanded(
          child: SingleChildScrollView(
            child: BlocBuilder<CartBloc, CartState>(
              bloc: BlocProvider.of<CartBloc>(context),
              builder: (context, state) {
                List<Product> productsInCart = state.cart.keys.toList();
                if (productsInCart.isNotEmpty) {
                  return DynamicGridView(
                    padding: const EdgeInsets.only(
                      top:5 ,
                      left: 20,
                      right: 20,
                      bottom: 20
                    ),
                    minItemSize: 500,
                    spacing: 20,
                    runSpacing: 20,
                    children: productsInCart
                      .map((product) => ProductItem(
                            product: product,
                          ))
                      .toList(),
                  );
                } else {
                  return Align(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset("assets/empty_cart.png")
                          ),
                          Text(
                            "Il carrello è vuoto",
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),        
      ],
    );
  }
}


