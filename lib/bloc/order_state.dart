// ignore_for_file: prefer_const_constructors_in_immutables

part of 'order_bloc.dart';

typedef Order = Map<Product, int>;

@immutable
sealed class OrderState {
  final List<Order> myOrders;
  const OrderState(this.myOrders); 
}

final class OrderInitial extends OrderState {
  OrderInitial() : super([]);
}

final class OrderPlaced extends OrderState{
  OrderPlaced(super.myOrders);
}

final class OrdersFetched extends OrderState{
  final List<Order> ordersReceived;
  OrdersFetched(super.myOrders, this.ordersReceived);
}

final class OrderError extends OrderState{
  final String error;
  final OrderEvent event;
  OrderError(this.error, this.event, super.myOrders);
}