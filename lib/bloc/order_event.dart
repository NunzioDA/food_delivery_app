part of 'order_bloc.dart';

@immutable
sealed class OrderEvent {
}

class FetchMyOrders extends OrderEvent{
  FetchMyOrders();
}

class ConfirmOrderEvent extends OrderEvent{
  final DeliveryInfo deliveryInfo;
  ConfirmOrderEvent(this.deliveryInfo);
}