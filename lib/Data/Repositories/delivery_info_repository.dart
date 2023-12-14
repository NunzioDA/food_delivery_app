import 'dart:convert';

import 'package:food_delivery_app/Data/APIs/delivery_info_api.dart';
import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';

class DeliveryInfoRepository{
  Future<List<DeliveryInfo>> fetchMyDeliveryInfos(
    LoggedInState user
  ) async
  {
    String json = await DeliveryInfoApi.fetchMyDeliveryInfos(
      user.username, 
      user.token
    );
      
    try{     
      return (jsonDecode(json) as List).map((e) => DeliveryInfo.fromJson(e)).toList();
    }
    catch(e){
      throw Exception(json);
    }
  }
}