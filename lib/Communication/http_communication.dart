import 'package:flutter/foundation.dart';
import 'package:food_delivery_app/cubit/connectivity_cubit.dart';
import 'package:http/http.dart' as http;

class FdaResponse
{
  bool successful;
  String body;
  FdaResponse(this.successful, this.body);
}

class ErrorCodes
{
  static Map<String, String> codes = {
    'successful_operation' : 'B000',
    'access_denied' : 'B001',
    'bad_request' : 'B002',
    'parameter_not_found' : 'B003',
    'wrong_request' : 'B004',
    'empty_result': 'B005',

    'failed_transition' : 'B101',

    'failed_username_validation' : 'B201',
    'failed_password_validation': 'B202',
    'wrong_username_or_password': 'B203',
    'username_already_used': 'B204',
    'failed_name_validation':'B205',
    'wrong_username_or_token' : "B206",

    'internal_api_error': 'B901'
  };

  static bool isSuccesfull(String code)
  {
    return code == codes['successful_operation'];
  }

  static bool isNotSuccesfull(String code)
  {
    return code != codes['successful_operation'] && codes.containsValue(code);
  }
}

class FdaServerCommunication
{
  static const bool serverSwitch = !kReleaseMode;  
  static ConnectivityCubit? currentConnectivityCubit;

  static String getServerBaseLink()
  {
    String protocol;
    if(serverSwitch) {
      protocol = "http://";
    } 
    else {
      protocol = "https://";
    }

    return "$protocol${getServerName()}";
  }

  static String getServerName()
  {    
    return const String.fromEnvironment("BACKEND");
  }

  static String getBackendFolder()
  {
    return "/FDA/backendFda";
  }


  static String getImageUrl(String imageName)
  {
    return "${getServerBaseLink()}${getBackendFolder()}"
            "/fetch_image.php?image=$imageName";
  }

  static Uri geBackendUri(String phpFile, Map<String, String>? parameters)
  {
    String serverName = getServerName();
    Uri uri;
    if(serverSwitch) {
      //http request
      uri = Uri.http(serverName,'${getBackendFolder()}/$phpFile.php', parameters);
    }
    else {
      //https request
      uri = Uri.https(serverName,'${getBackendFolder()}/$phpFile.php', parameters);
    }
    return uri;
  }

  static Future<http.Response> getRequest(String phpFile, [Map<String, String>? parameters]) async {
    // print(geBackendUri(phpFile, parameters));
    try{
      http.Response response = await http.get(geBackendUri(phpFile, parameters));
      return response;
    }catch(e)
    {
      currentConnectivityCubit?.checkConnectivityCommunication();
      rethrow;
    }
    
  }

  static Future<http.Response> postRequest(
    String phpFile, 
    {Map<String, String>? getParameters, Map<String, String>? body}) async{    
    try{
      http.Response response = await http.post(geBackendUri(phpFile, getParameters ?? {}), body: body);
      return response;
    }catch(e)
    {
      currentConnectivityCubit?.checkConnectivityCommunication();
      rethrow;
    }
  }
}
