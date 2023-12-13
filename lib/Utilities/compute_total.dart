import 'package:food_delivery_app/Data/Model/product.dart';

double getTotal(Map<Product, int> product) {
  return product.entries.fold(
      0,
      (previousValue, element) =>
          previousValue + (element.value * element.key.price));
}