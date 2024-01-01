import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:meta/meta.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  late final StreamSubscription subscription;
  Timer? connectionCheckTimer;
  bool canCheckConnection = true;

  ConnectivityCubit() : super(FirstCheck()){
    subscription = Connectivity().onConnectivityChanged.listen(_manageConnectivityResult);
    Connectivity().checkConnectivity().then(_manageConnectivityResult);
    FdaServerCommunication.currentConnectivityCubit = this;
  }

  void _manageConnectivityResult(ConnectivityResult result) async
  {
    switch(result)
    {      
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile: 
      case ConnectivityResult.wifi:
        print("rilevata connessione");
        checkConnectivityCommunication();
      break;
      case ConnectivityResult.none:
        print("persa connessione");
        if(state is Connected || state is FirstCheck){
          emit(NotConnected(state is Connected));
          canCheckConnection = true;
          _stopCommunicationCheckerIfAvailable();
        }
      default:
        
    }
  }

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

  void _startConnectionChecker()
  {
    canCheckConnection = true;
    connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 5), 
      (timer) { 
        if(canCheckConnection)
        {                  
          checkConnectivityCommunication();
          canCheckConnection = false;  
        }
      }
    );
  }

  void _stopCommunicationCheckerIfAvailable()
  {
    connectionCheckTimer?.cancel();
    connectionCheckTimer = null;
  }

  void checkConnectivityCommunication() async
  {
    if(canCheckConnection)
    {
      String response;
      try{
        response = (await FdaServerCommunication.getRequest("check")).body;
      }
      catch(e)
      {
        response = e.toString();
      }
      canCheckConnection = true;
      if(ErrorCodes.isSuccesfull(response))
      {        
        print("connesso");    
        emit(Connected(state is NotConnected));
        _stopCommunicationCheckerIfAvailable();
      }
      else{
        print("connesso ma non disponibile");   
        emit(AvailableButNotConnected(state is Connected));
        if(connectionCheckTimer == null)
        {
          _startConnectionChecker();
        }
      }
    }
  }


  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
