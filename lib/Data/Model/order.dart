import 'package:food_delivery_app/Data/Model/product.dart';

class Order{
  final String username;
  final String address;
  final List<Product> products;
  final DateTime dateTime;

  const Order(
    this.username, 
    this.address, 
    this.products, 
    this.dateTime
  );
}