import 'dart:convert';

import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/APIs/user_api.dart';
import 'package:food_delivery_app/Data/Model/fda_user.dart';
class UserRepository{

  Future<String> login(String username, String password) async
  {
    String result = await UserApi.login(username, password);
    return result;
  }

  Future<String> signup(
    String name, 
    String username, 
    String password
  ) async
  {
    String result =  await UserApi.signup(name, username, password);
    return result;
  }

  Future<bool> verifyLoggedInState(String username, String token) async
  {    
    return await UserApi.verifyLoggedInState(
      username, 
      token
    ).then((result) => result == "YES");
  }

  Future<bool> logout(String username, String token) async
  {
    String result = await UserApi.logout(username, token);
    return ErrorCodes.isSuccesfull(result);
  }

  Future<FdaUserInfo> fetchUserInfo(String username, String token) async
  {
    String json = await UserApi.fetchUserInfo(
      username,
      token
    );


    if(!ErrorCodes.isNotSuccesfull(json) && json != ErrorCodes.codes['empty_result']) {      
      return FdaUserInfo.fromJson(jsonDecode(json));
    }
    else {
      throw Exception(json);
    }
  }

  // Future<bool> changeUserinfo(
  //   LoggedInState userState,
  //   String newName
  // ) async
  // {    
  //   return ErrorCodes.isSuccesfull(
  //     await UserApi.changeUserinfo(
  //       userState.username, 
  //       userState.token, 
  //       newName
  //     )
  //   );
  // }

}