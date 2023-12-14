import 'package:food_delivery_app/Communication/http_communication.dart';

class OrderApi
{
  static Future<String> confirmOrder(
    String username,
    String token,
    String city,
    String intercom,
    String address,
    String houseNumber
  ) async
  {
     return await FdaServerCommunication.getRequest(
      "place_order", 
      {
        "username": username,
        "token": token,
        "city": city,
        "intercom": intercom,
        "address": address,
        "house_number": houseNumber,
      },
    ).then((value) {
      return value.body;
    });
  } 

  static Future<String> fetchOrders(
    String username,
    String token,
    String mode,
  ) async
  {
     return await FdaServerCommunication.getRequest(
      "fetch_orders", 
      {
        "username": username,
        "token": token,
        "mode": mode
      },
    ).then((value) {
      return value.body;
    });
  } 

  static Future<String> updateOrder(
    String username,
    String token,
    String orderId,
    String newStatus,
  ) async
  {
     return await FdaServerCommunication.getRequest(
      "change_order_status", 
      {
        "username": username,
        "token": token,
        "order_id": orderId,
        "new_status": newStatus,
      },
    ).then((value) {
      return value.body;
    });
  } 
}