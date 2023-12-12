import 'package:food_delivery_app/bloc/cart_bloc.dart';

double getTotal(CartState state) {
  return state.cart.entries.fold(
      0,
      (previousValue, element) =>
          previousValue + (element.value * element.key.price));
}