import 'package:food_delivery_app/Communication/http_communication.dart';

class DeliveryInfoApi
{
  static Future<String> fetchMyDeliveryInfos(
    String username,
    String token
  ) async
  {
    return await FdaServerCommunication.getRequest(
      "fetch_my_recent_delivery_info", 
      {
        "username":username,
        "token":token,
      },
    ).then((value) {
      return value.body;
    });
  }
}