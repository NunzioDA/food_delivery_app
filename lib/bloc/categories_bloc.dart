import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/product.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Data/Repositories/categories_repository.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository _repository = CategoryRepository();
  final UserBloc _userBloc;
  // final ConnectivityCubit _connectivityCubit;
  // late final StreamSubscription _connectivitySubscription;
  
  CategoriesBloc(this._userBloc) : super(CategoriesInitial()) {

    // _connectivitySubscription = _connectivityCubit.stream.listen((event) {
    //   if(event is NotConnected)
    //   {
    //     add(_EmptyCategories());
    //   }
    // });

    on<CategoriesEvent>((event, emit) async{
      switch(event)
      {
        case CategoriesFetchEvent():
          try{
            List<ProductsCategory> categories 
              = await _repository.fetchCategories();

            emit(CategoriesFetched(categories));
          }
          catch(e)
          {
            emit(
              CategoriesErrorState(
                state.categories, 
                e.toString(), 
                event
              )
            );
          }          
        break;

        case CategoriesCreateEvent():
          String result = await _repository.createCategory(
            event.newCategory,
            event.newImage,
            _userBloc.state as LoggedInState
          );

          if(ErrorCodes.isSuccesfull(result))
          {
            emit(CategoryCreatedSuccesfully(state.categories));
          }
          else if(result.contains("Duplicate entry"))
          {
            emit(CategoryAlreadyExisting(state.categories));
          }
          else{
            emit(CategoriesErrorState(
              state.categories, 
              "Some error occured : $result", 
              event
            ));
          }
        break;

        case CategoryDeleteEvent():
          String result = await _repository.deleteCategory(
            event.category, 
            _userBloc.state as LoggedInState
          );

          if(ErrorCodes.isSuccesfull(result))
          {
            emit(CategoryDeletedSuccesfully(state.categories));
          }
          else{
            emit(CategoriesErrorState(
              state.categories, 
              "Some error occured : $result", 
              event
            ));
          }
        break;

        case ProductCreateEvent():
          String result = await _repository.createProduct(
            event.category, 
            event.product, 
            event.image, 
            _userBloc.state as LoggedInState
          );

          if(ErrorCodes.isSuccesfull(result))
          {
            emit(ProductCreatedSuccesfully(state.categories));
          }
          else{
             emit(CategoriesErrorState(
              state.categories, 
              "Some error occured : $result", 
              event
            ));
          }
        break;

        case ProductDeleteEvent():
          String result = await _repository.deleteProduct(
            event.product, 
            _userBloc.state as LoggedInState
          );

          if(ErrorCodes.isSuccesfull(result))
          {
            emit(ProductDeletedSuccesfully(state.categories));
          }
          else{
            emit(CategoriesErrorState(
              state.categories, 
              "Some error occured : $result", 
              event
            ));
          }
        break;
        case _EmptyCategories():
        emit(const CategoriesFetched([]));
        break;
      }
    });
  }

  @override
  Future<void> close() {
    // _connectivitySubscription.cancel();
    return super.close();
  }
}
