import 'package:food_delivery_app/Communication/http_communication.dart';

class CartApi{
  static Future<String> fetchCart(
    String username,
    String token
  ) async
  {
    return await FdaServerCommunication.getRequest(
      "fetch_cart", 
      {
        "username":username,
        "token":token,
      },
    ).then((value) {
      return value.body;
    });
  }

  static Future<String> addProduct(
    String productId,
    String username,
    String token
  )async
  {
    return await FdaServerCommunication.getRequest(
      "add_product_to_cart", 
      {
        "username":username,
        "token":token,
        "product_id":productId
      },
    ).then((value) {
      return value.body;
    });
  }

  static Future<String> removeProduct(
    String productId,
    bool removeAll,
    String username,
    String token
  )async
  {
    return await FdaServerCommunication.getRequest(
      "remove_product_from_cart", 
      {
        "username": username,
        "token": token,
        "product_id": productId,
        "remove_all": removeAll? "1": "0"
      },
    ).then((value) {
      return value.body;
    });
  }
}