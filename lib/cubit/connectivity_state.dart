part of 'connectivity_cubit.dart';

@immutable
sealed class ConnectivityState {}

final class FirstCheck extends ConnectivityState{}

final class NotConnected extends ConnectivityState{
  final bool lost;
  NotConnected(this.lost);
}

final class AvailableButNotConnected extends NotConnected{
  AvailableButNotConnected(super.lost);
}

final class Connected extends ConnectivityState{
  final bool restored;
  Connected(this.restored);
}