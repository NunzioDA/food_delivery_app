part of 'user_bloc.dart';

@immutable
sealed class UserState {
  const UserState();
}

class NotLoggedState extends UserState{
  const NotLoggedState();
}

class VerifiedNotLoggedState extends NotLoggedState{
  const VerifiedNotLoggedState();
}

class CorrectlySignedinState extends NotLoggedState{
  const CorrectlySignedinState();
}

class WrongUsernameOrPasswordState extends NotLoggedState{
}

class InvalidPasswordState extends NotLoggedState{
  const InvalidPasswordState();
}

class InvalidUsernameState extends NotLoggedState{
  const InvalidUsernameState();
}

class UsernameAlreadyUsedState extends NotLoggedState{
  const UsernameAlreadyUsedState();
}

class LoggedInState extends UserState{
  final String username;
  final String token;

  const LoggedInState({
    required this.username,
    required this.token, 
  });
}

class LoggedOut extends NotLoggedState{
  const LoggedOut();
}

class FetchedUserInfoState extends LoggedInState{
  final FdaUserInfo userInfo;
  const FetchedUserInfoState({
    required this.userInfo,
    required super.username,
    required super.token
  });
}


class UserErrorState extends NotLoggedState{
  final String error;
  final UserEvent event;
  const UserErrorState({
    required this.error, 
    required this.event
  });
}

class UserErrorLoggedInState extends LoggedInState{
  final String error;
  final UserEvent event;
  const UserErrorLoggedInState({
    required this.error, 
    required this.event,
    required super.username,
    required super.token,
  });
}