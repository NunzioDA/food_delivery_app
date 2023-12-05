import 'package:food_delivery_app/Communication/http_communication.dart';

class CategoryApi{
  static Future<String> fetchCategories() async
  {
    return await FdaServerCommunication.getRequest(
      "fetch_products_categories", 
      {}
    ).then((value) {
      return value.body;
    });
  }
}