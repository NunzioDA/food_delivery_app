// ignore_for_file: prefer_const_constructors_in_immutables

part of 'order_bloc.dart';

@immutable
sealed class OrderState {
}

final class OrderInitial extends OrderState {
  OrderInitial();
}

final class OrderPlaced extends OrderState{}

final class OrdersFetched extends OrderState{
  final List<Order> orders;
  OrdersFetched(this.orders);
}

final class OrderUpdated extends OrdersFetched{
  OrderUpdated(super.orders);
}

final class OrderError extends OrderState{
  final String error;
  final OrderEvent event;
  OrderError(this.error, this.event);
}