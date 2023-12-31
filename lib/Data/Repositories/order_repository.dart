import 'dart:convert';

import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/APIs/order_api.dart';
import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';

class OrderRepository
{
  Future<FdaResponse> confirmOrder(
    LoggedInState user,
    DeliveryInfo info
  ) async
  {
    String response = await OrderApi.confirmOrder(
      user.username, 
      user.token,
      info.city,
      info.intercom,
      info.address,
      info.houseNumber
    );
    return FdaResponse(ErrorCodes.isSuccesfull(response), response);
  } 

  Future<List<Order>> _fetchOrders(
    LoggedInState user,
    String mode
  ) async
  {
    String json = await OrderApi.fetchOrders(
      user.username, 
      user.token,
      mode
    );
    var orders = (jsonDecode(json) as List).map((e){
      return Order.fromJson(e);
    }).toList();

    orders.sort((a, b) => b.dateTime.compareTo(a.dateTime),);

    return orders;
  }

  
  Future<List<Order>> fetchMyOrders(
    LoggedInState user
  ) async
  {
    return _fetchOrders(user, "normal");
  }

  Future<List<Order>> fetchReceivedOrders(
    LoggedInState user
  ) async
  {
    return _fetchOrders(user, "management");
  } 

  Future<List<Order>> updateOrder(
    LoggedInState user,
    Order order,
    OrderStatus newStatus
  ) async
  {
    String response = await OrderApi.updateOrder(
      user.username, 
      user.token, 
      order.id, 
      newStatus.name
    );

    if(ErrorCodes.isSuccesfull(response))
    {
      return fetchReceivedOrders(user);
    }
    
    throw Exception(response);
  }
}