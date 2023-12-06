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

  static Future<String> createCategory(
    String categoryName,
    String username,
    String token,
    String image
  ) async{
    return await FdaServerCommunication.getRequest(
      "create_products_category", 
      {
        "name":categoryName,
        "username":username,
        "token":token,
        "image":image
      }
    ).then((value) {
      return value.body;
    });
  }
}