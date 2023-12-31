part of 'user_bloc.dart';

@immutable
sealed class UserEvent {
  const UserEvent();
}

class SignupEvent extends UserEvent
{
  final String name;
  final String username;
  final String password;
  const SignupEvent(this.name, this.username, this.password);
}

class LoginEvent extends UserEvent
{
  final String username;
  final String password;
  const LoginEvent(this.username, this.password);
}

class LogoutEvent extends UserEvent
{
  const LogoutEvent();
}

class VerifyLoggedInEvent extends UserEvent
{
  const VerifyLoggedInEvent();
}

class FetchUserInfoEvent extends UserEvent
{
  const FetchUserInfoEvent();
}