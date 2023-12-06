part of 'categories_bloc.dart';

@immutable
sealed class CategoriesEvent {
  const CategoriesEvent();
}

class CategoriesFetchEvent extends CategoriesEvent{
  const CategoriesFetchEvent();  
}

class CategoriesCreateEvent extends CategoriesEvent{
  final ProductsCategory newCategory;
  final XFile newImage;
  const CategoriesCreateEvent(this.newCategory, this.newImage);
}