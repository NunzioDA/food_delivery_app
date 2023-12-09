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
    return await FdaServerCommunication.postRequest(
      "create_products_category", 
      getParameters: {
        "name":categoryName,
        "username":username,
        "token":token,
      },
      body: {        
        "image":image
      }
    ).then((value) {
      return value.body;
    });
  }


  static Future<String> deleteCategory(
    String categoryName,
    String username,
    String token,
  ) async{
    return await FdaServerCommunication.getRequest(
      "delete_products_category", 
      {
        "name":categoryName,
        "username":username,
        "token":token,
      },
    ).then((value) {
      return value.body;
    });
  }

  static Future<String> createProduct(
    String categoryName,
    String productName,
    String productDescription,
    String productPrice,
    String username,
    String token,
    String image
  ) async{
    return await FdaServerCommunication.postRequest(
      "create_product", 
      getParameters: {
        "name":productName,
        "description":productDescription,
        "price":productPrice,
        "category_name":categoryName,
        "username":username,
        "token":token,
      },
      body: {
        "image":image
      }
    ).then((value) {
      return value.body;
    });
  }

  static Future<String> deleteProduct(
    String productId,
    String username,
    String token,
  ) async{
    return await FdaServerCommunication.getRequest(
      "delete_product", 
      {
        "id":productId,
        "username":username,
        "token":token,
      },
    ).then((value) {
      return value.body;
    });
  }
}