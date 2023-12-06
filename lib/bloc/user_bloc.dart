import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<UserEvent>((event, emit) {
      //  if(result.contains(".token")){
        
      //   String token = result.substring(0, result.indexOf(".token"));

      //   final prefs = await SharedPreferences.getInstance();
      //   await prefs.setString('username', username); 
      //   await prefs.setString('token', token); 

      //   // BamsServerCommunication.currentUser.username = username;
      //   // BamsServerCommunication.currentUser.token = token;
      //   return LoggedInState(
      //     username: username, 
      //     token: token
      //   );
      // }
      // else if (result == ErrorCodes.codes['wrong_username_or_password'])
      // {
      //   throw const WrongUsernameOrPasswordState();
      // }


      // if(token == null && username == null)
      // {
      //   SharedPreferences pref = await SharedPreferences.getInstance();
      //   token = pref.getString("token");
      //   username = pref.getString("username");
      // }
    });
  }
}
