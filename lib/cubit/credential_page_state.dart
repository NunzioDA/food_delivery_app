part of 'credential_page_cubit.dart';

@immutable
sealed class CredentialPageState {}

class LoginMode extends CredentialPageState{}

class SignupMode extends CredentialPageState{}