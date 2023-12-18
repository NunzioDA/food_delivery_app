import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:meta/meta.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  late final StreamSubscription subscription;

  String stateToMessage()
  {
    switch(state)
    {
      case AvailableButNotConnected():
        return "Connessione a internet non disponibile.";
      case NotConnected():
        return "Non sei connesso";
      case Connected():
        return "Sei connesso";
      case FirstCheck():
        return "Non pervenuto";
    }
  }

  void _manageConnectivityResult(ConnectivityResult result) async
  {
    switch(result)
    {
      
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile: 
      case ConnectivityResult.wifi:
        if(state is NotConnected || state is FirstCheck)
        {
          checkConnectivityCommunication();
        }
      break;
      case ConnectivityResult.none:
        if(state is Connected || state is FirstCheck) emit(NotConnected(state is Connected));
      default:
    }
  }

  void checkConnectivityCommunication() async
  {
    String response;
    try{
      response = (await FdaServerCommunication.getRequest("check", {})).body;
    }
    catch(e)
    {
      response = e.toString();
    }
    
    if(ErrorCodes.isSuccesfull(response))
    {            
      emit(Connected(state is NotConnected));
    }
    else{
      emit(AvailableButNotConnected(state is Connected));
    }
  }

  ConnectivityCubit() : super(FirstCheck()){
    subscription = Connectivity().onConnectivityChanged.listen(_manageConnectivityResult);
    print("check");
    Connectivity().checkConnectivity().then(_manageConnectivityResult);
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
