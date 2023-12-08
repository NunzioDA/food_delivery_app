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

final class CategoryAlreadyExisting extends CategoriesState{
  const CategoryAlreadyExisting(super.categories);
}

final class CategoryDeletedSuccesfully extends CategoriesState{
  const CategoryDeletedSuccesfully(super.categories);
}

final class ProductCreatedSuccesfully extends CategoriesState{
  const ProductCreatedSuccesfully(super.categories);
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