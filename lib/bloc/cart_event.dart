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
  const RemoveProductFromCart(this.product);
}

class FetchCart extends CartEvent{
  final Cart? previewsCart;
  const FetchCart([this.previewsCart]);
}