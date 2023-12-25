part of 'cart_bloc.dart';

@immutable
sealed class CartEvent {
  const CartEvent();
}

class AddProductToCart extends CartEvent{
  final Product product;
  const AddProductToCart(this.product);
}

class RemoveProductFromCart extends CartEvent{
  final Product product;
  final bool removeAll;
  const RemoveProductFromCart(this.product, [this.removeAll=false]);
}

class FetchCart extends CartEvent{
  final Cart? previousCart;
  const FetchCart([this.previousCart]);
}

class _EmptyCart extends CartEvent{
  const _EmptyCart();
}