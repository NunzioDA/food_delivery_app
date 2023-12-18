part of 'user_bloc.dart';

@immutable
sealed class UserState {
}

class NotLoggedState extends UserState{
  NotLoggedState();
}

class VerifiedNotLoggedState extends NotLoggedState{
  VerifiedNotLoggedState();
}

class CorrectlySignedinState extends NotLoggedState{
  CorrectlySignedinState();
}

class WrongUsernameOrPasswordState extends NotLoggedState{
}

class InvalidPasswordState extends NotLoggedState{
  InvalidPasswordState();
}

class InvalidUsernameState extends NotLoggedState{
  InvalidUsernameState();
}

class UsernameAlreadyUsedState extends NotLoggedState{
  UsernameAlreadyUsedState();
}

class LoggedInState extends UserState{
  final String username;
  final String token;

  LoggedInState({
    required this.username,
    required this.token, 
  });
}

class VerifiedLoggedInState extends LoggedInState{
  VerifiedLoggedInState({required super.username, required super.token});
}

class LoggedOut extends NotLoggedState{
  LoggedOut();
}

class FetchedUserInfoState extends LoggedInState{
  final FdaUserInfo userInfo;
  FetchedUserInfoState({
    required this.userInfo,
    required super.username,
    required super.token
  });
}


class UserErrorState extends NotLoggedState{
  final String error;
  final UserEvent event;
  UserErrorState({
    required this.error, 
    required this.event
  });
}

class UserErrorLoggedInState extends LoggedInState{
  final String error;
  final UserEvent event;
  UserErrorLoggedInState({
    required this.error, 
    required this.event,
    required super.username,
    required super.token,
  });
}