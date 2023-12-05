import 'package:food_delivery_app/Data/Model/product.dart';

class ProductsCategory{
  final String name;
  final String imageName;
  final List<Product> products;

  const ProductsCategory(
    this.name,
    this.imageName,
    this.products
  );

  ProductsCategory.fromJson(Map<String, dynamic> json):
    name = json["name"],
    imageName = json["image"],
    products = ((json["products"] as List).map(
      (e) => Product.fromJson(e)
    )).toList();

}