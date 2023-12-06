part of 'categories_bloc.dart';

@immutable
sealed class CategoriesState {
  final List<ProductsCategory> categories;
  const CategoriesState(this.categories);
}

final class CategoriesInitial extends CategoriesState{
  CategoriesInitial():super(List.empty());
}

final class CategoriesFetched extends CategoriesState{
  const CategoriesFetched(super.categories);
}

final class CategoryCreatedSuccesfully extends CategoriesState{
  const CategoryCreatedSuccesfully(super.categories);
}

final class CategoriesErrorState extends CategoriesState{
  final String error;
  final CategoriesEvent event;
  const CategoriesErrorState(
    super.categories, 
    this.error,
    this.event
  );
}