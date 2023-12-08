import 'package:bloc/bloc.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<CartEvent>((event, emit) {
      switch(event)
      {        
        case AddProductToCart():
          var products = state.products;

          if(products.containsKey(event.product))
          {
            products[event.product] = products[event.product]! + 1; 
          }
          else {
            products[event.product] = 1;
          }

          emit(CartProductAdded(event.product, products));

          break;
        case RemoveProductFromCart():
          var products = state.products;

          if(products.containsKey(event.product))
          {
            if(products[event.product]! > 1)
            {
              products[event.product] = products[event.product]! - 1;
            }
            else {
              products.remove(event.product);
            }
          }

          emit(CartProductRemoved(event.product, products));
          break;
      }
    });
  }
}
