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
}