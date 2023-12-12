import 'package:bloc/bloc.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Data/Repositories/cart_repository.dart';
import 'package:food_delivery_app/bloc/categories_bloc.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final UserBloc _userBloc;
  final CategoriesBloc _categoriesBloc;
  final CartRepository _cartRepository = CartRepository();

  CartBloc(this._userBloc, this._categoriesBloc) : super(CartInitial()) {

    _userBloc.stream.listen((event) { 

      Cart? previewsCart;

      if(event is LoggedInState && 
      event is! FetchedUserInfoState &&
      event is! UserErrorLoggedInState
      )      
      {
        previewsCart = state.cart;        
      }
      
      add(FetchCart(previewsCart));
    });

    on<CartEvent>((event, emit) async{
      switch(event)
      {        
        case AddProductToCart():

          try{
            Cart cart = await _cartRepository.addProduct(
              event.product, 
              _userBloc.state, 
              state.cart,
              _categoriesBloc.state.categories
            );  

            emit(CartProductAdded(event.product, cart));
          }
          catch(e){
            emit(CartError(
                state.cart, 
                error: e.toString(), 
                event: event
              )
            );
          }

          break;  
        case RemoveProductFromCart():
          
          try{
            Cart cart = await _cartRepository.removeProduct(
              event.product, 
              _userBloc.state, 
              state.cart,
              _categoriesBloc.state.categories
            );

            emit(CartProductRemoved(event.product, cart));
          }
          catch(e){
            emit(CartError(
                state.cart, 
                error: e.toString(), 
                event: event
              )
            );
          }
          break;

        case FetchCart():
          try{
            Cart cart = await _cartRepository.fetchCart(
              _userBloc.state, 
              _categoriesBloc.state.categories,
              event.previewsCart
            );
            
            emit(CartFetched(cart));
          }
          catch(e){
            emit(CartError(
              state.cart, 
              error: e.toString(), 
              event: event
            ));
          }
          break;
      }
    });
  }
}
