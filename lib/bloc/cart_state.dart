part of 'cart_bloc.dart';

@immutable
sealed class CartState {
  final Map<Product, int> products;
  const CartState(this.products);
}

class CartInitial extends CartState
{
  CartInitial() : super({});
}

class CartProductAdded extends CartState
{
  final Product addedProduct;
  const CartProductAdded(this.addedProduct, super.products);
}

class CartProductRemoved extends CartState
{
  final Product removedProduct;
  const CartProductRemoved(this.removedProduct, super.products);
}

class CartError extends CartState
{
  final String error;
  final CartEvent event;
  const CartError(
    super.products,
    {
      required this.error,
      required this.event,
    }  
  );
}