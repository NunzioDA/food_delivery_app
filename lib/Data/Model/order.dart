import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/Data/Model/product.dart';

class Order{
  final String username;
  final DeliveryInfo deliveryInfo;
  final Map<Product, int> content;
  final DateTime dateTime;

  const Order(
    this.username, 
    this.deliveryInfo, 
    this.content, 
    this.dateTime
  );


  Order.fromJson(Map<String, dynamic> json) :
    username = json["username"],
    deliveryInfo = DeliveryInfo.fromJson(json),
    dateTime = DateTime.parse(json["date_time"]),
    content = { 
      for (var element in json["products"] as List) 
        Product.fromJson(element) : element["product_count"]
    };
}