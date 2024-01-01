import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:meta/meta.dart';

part 'connectivity_state.dart';

/// Gestisce gli eventi sulla connettività, distinguendo 
/// 3 stati diversi:
/// 
/// [Connected] connessione presente e attiva
/// [NotConnected] connessione assente
/// [AvailableButNotConnected] connessione presente ma non è possibile comunicare
/// 
/// Per il check della presenza di una connessione, si basa su [Connectivity]
/// che fornisce uno stream di eventi sulla connettività del dispositivo.
/// Mentre per il check della comunicazione effettua una richiesta http al 
/// backend, verso l'apposita API "check" che fornisce un messaggio di successo.

class ConnectivityCubit extends Cubit<ConnectivityState> {
  late final StreamSubscription subscription;
  Timer? connectionCheckTimer;
  bool canCheckConnection = true;

  ConnectivityCubit() : super(FirstCheck()){
    subscription = Connectivity().onConnectivityChanged.listen(_manageConnectivityResult);
    Connectivity().checkConnectivity().then(_manageConnectivityResult);
    FdaServerCommunication.currentConnectivityCubit = this;
  }

  /// Gestisce gli eventi di connettività restituito da [Connectivity]
  void _manageConnectivityResult(ConnectivityResult result) async
  {
    switch(result)
    {      
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile: 
      case ConnectivityResult.wifi:
        checkConnectivityCommunication();
      break;
      case ConnectivityResult.none:
        if(state is Connected || state is FirstCheck){
          emit(NotConnected(state is Connected));
          canCheckConnection = true;
          _stopCommunicationCheckerIfAvailable();
        }
      default:
        
    }
  }

  /// Trasforma lo stato della connessione in un messaggio visualizzabile

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

  /// Avvia un checker della connessione
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

  /// Se dovesse essere attivo un checker della comunicazione, lo ferma.
  void _stopCommunicationCheckerIfAvailable()
  {
    connectionCheckTimer?.cancel();
    connectionCheckTimer = null;
  }


  /// Effettua il check della comunicazione se possibile
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
        emit(Connected(state is NotConnected));
        _stopCommunicationCheckerIfAvailable();
      }
      else{
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
