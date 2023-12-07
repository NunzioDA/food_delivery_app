import 'package:bloc/bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/fda_user.dart';
import 'package:food_delivery_app/Data/Repositories/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository = UserRepository();

  UserBloc() : super(const NotLoggedState()) {
    on<UserEvent>((event, emit) async{

      switch(event)
      {        
        case SignupEvent():
          try{
            String result = await _userRepository.signup(
              event.name, 
              event.username, 
              event.password
            );

            if(ErrorCodes.isSuccesfull(result))
            {
              emit(const CorrectlySignedinState());
            }
            else if(ErrorCodes.codes["username_already_used"]! == result){
              emit(const UsernameAlreadyUsedState());
            }
            else{
              emit(
                UserErrorState(
                  error: "Some error during sign in occurredd",
                  event: event,              
                )
              );
            }
          }
          catch(e){
            emit(
              UserErrorState(
                error: e.toString(),
                event: event,              
              )
            );
          }

          break;
        case LoginEvent():
          try{
            String result = await _userRepository.login(
              event.username, 
              event.password
            );

            if(result.contains(".token")){
              String token = result.substring(0, result.indexOf(".token"));
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', event.username); 
              await prefs.setString('token', token); 

              emit(
                LoggedInState(
                  username: event.username, 
                  token: token
                )
              );
            }
            else if(result.contains(ErrorCodes.codes["wrong_username_or_password"]!))
            {
              emit(WrongUsernameOrPasswordState());
            }
            else{
              emit(
                UserErrorState(
                  error: result,
                  event: event,              
                )
              );
            }

          } 
          catch(e){
            emit(
              UserErrorState(
                error: e.toString(),
                event: event,              
              )
            );
          }
          break;
        case LogoutEvent():
          LoggedInState user = state as LoggedInState;
          bool result = await _userRepository.logout(
            user.username,
            user.token
          );

          if(result)
          {
            emit(const LoggedOut());
          }
          else{
            emit(
              UserErrorState(
                error: "Some error occurred", 
                event: event
              )
            );
          }
          break;
        case VerifyLoggedInEvent():
          String? token;
          String? username;
          
          if(state is LoggedInState)
          {
            LoggedInState user = state as LoggedInState;
            token = user.token;
            username = user.username;
          }

          if(token == null && username == null)
          {
            SharedPreferences pref = await SharedPreferences.getInstance();
            token = pref.getString("token");
            username = pref.getString("username");
          }

          if(token != null && username != null)
          {
            bool result = await _userRepository.verifyLoggedInState(username, token);
            if(result)
            {
              emit(
                LoggedInState(
                  username: username, 
                  token: token
                )
              );
            }
            else {
              emit(const VerifiedNotLoggedState());
            }
          }
          else {
            emit(const VerifiedNotLoggedState());
          }

          break;
        case FetchUserInfoEvent():
          LoggedInState user = state as LoggedInState;
          try{
            FdaUserInfo userInfo = await _userRepository.fetchUserInfo(
              user.username, 
              user.token
            );
            emit(
              FetchedUserInfoState(
                userInfo: userInfo, 
                username: user.username, 
                token: user.token
              )
            );
          }
          catch(e){
            if(state is LoggedInState)
            {
              emit(
                UserErrorLoggedInState(
                  error: e.toString(), 
                  event: event, 
                  username: (state as LoggedInState).username, 
                  token: (state as LoggedInState).token
                )
              );
            }
            else{
              emit(
                UserErrorState(
                  error: "Cant fetch user info if not logged in", 
                  event: event, 
                )
              );
            }
          }
          break;
        case ChangeUserInfoEvent():
          // TODO: Handle this case.
          break;
      }
    });
  }
}
