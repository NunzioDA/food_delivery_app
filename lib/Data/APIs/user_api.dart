import 'package:food_delivery_app/Communication/http_communication.dart';

class UserApi{
  static Future<String> signIn(String name, String username, String password)
  {
    return FdaServerCommunication.getRequest("signin", {
      "name" : name,
      "username" : username,
      "password" : password
    }).then((value) {      
      return value.body;  
    });
  }

  static Future<String> verifyLoggedInState(String username, String token) async{

    return FdaServerCommunication.getRequest("is_token_active", {
      "username" : username,
      "token" : token,
    }).then((value) {
      return value.body;
    });
  }

  static Future<String> login(String username, String password)
  {
    return FdaServerCommunication.getRequest("login", {
      "username" : username,
      "password" : password
    }).then((value) async{
      return value.body;
    });
  }

  static Future<String> logout(String username, String token)
  {
    return FdaServerCommunication.getRequest("logout", {
      "username" : username,
      "token" : token
    }).then((value) {      
      return value.body;   
    });
  }

  static Future<String> fetchUserInfo(
    String username,
    String token
  )
  {
    return FdaServerCommunication.getRequest("fetch_user_info", {
      "username" : username,
      "token" : token
    }).then((value) {      
      return value.body;
    });
  }

  static Future<String> changeUserinfo(
    String username,
    String token,
    String newName
  ) async
  {    
    return await FdaServerCommunication.getRequest("change_user_info", {
      "username" : username,
      "token" : token,
      "new_name" : newName
    }).then((value) {
      return value.body;
    });
  }
}