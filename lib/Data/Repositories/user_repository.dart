import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/APIs/user_api.dart';
import 'package:food_delivery_app/Data/Model/fda_user.dart';
class UserRepository{

  Future<FdaUser> login(String username, password) async
  {
    String result = await UserApi.login(username, password);
   
    
    throw Exception(result);
  }

  Future<String> signIn(String name, String username, String password) async
  {
    String result =  await UserApi.signIn(name, username, password);
    if(ErrorCodes.codes.containsValue(result))
    {
      return result;
    }
    else {
      throw Exception(result);
    }
  }

  Future<bool> verifyLoggedInState(FdaUser user) async
  {    
    return await UserApi.verifyLoggedInState(
      user.username, 
      user.token!
    ).then((result) => result == "YES");
  }

  Future<bool> logout(FdaUser user) async
  {
    String result = await UserApi.logout(user.username, user.token!);
    return ErrorCodes.isSuccesfull(result);
  }

  Future<FdaUserInfo> fetchUserInfo(
    FdaUser user
  ) async
  {
    String json = await UserApi.fetchUserInfo(
      user.username,
      user.token!
    );
    
    if(!ErrorCodes.isNotSuccesfull(json) && json != ErrorCodes.codes['empty_result']) {      
      return FdaUserInfo.fromJson(json, user);
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