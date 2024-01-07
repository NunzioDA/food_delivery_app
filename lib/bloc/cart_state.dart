part of 'cart_bloc.dart';

@immutable
sealed class CartState {
  final Cart cart;
  const CartState(this.cart);
}

class CartInitial extends CartState
{
  CartInitial() : super({});
}

class CartProductAdded extends CartState
{
  final Product addedProduct;
  const CartProductAdded(this.addedProduct, super.cart);
}

class CartProductRemoved extends CartState
{
  final Product removedProduct;
  const CartProductRemoved(this.removedProduct, super.cart);
}

class CartFetched extends CartState
{
  const CartFetched(super.cart);
}


class CartError extends CartState
{
  final String error;
  final CartEvent event;
  const CartError(
    super.cart,
    {
      required this.error,
      required this.event,
    }  
  );
}