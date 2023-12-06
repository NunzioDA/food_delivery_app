import 'package:bloc/bloc.dart';
import 'package:food_delivery_app/Data/Model/products_category.dart';
import 'package:food_delivery_app/Data/Repositories/categories_repository.dart';
import 'package:meta/meta.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository _repository = CategoryRepository();

  CategoriesBloc() : super(CategoriesInitial()) {
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
          
        break;
      }
    });
  }
}
