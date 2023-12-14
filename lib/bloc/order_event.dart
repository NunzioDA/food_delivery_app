part of 'order_bloc.dart';

@immutable
sealed class OrderEvent {
}

class FetchMyOrders extends OrderEvent{
  FetchMyOrders();
}

class UpdateOrder extends OrderEvent{
  final Order order;
  final OrderStatus newStatus;
  UpdateOrder(this.order, this.newStatus);
}

class FetchReceivedOrders extends OrderEvent{
  FetchReceivedOrders();
}

class ConfirmOrderEvent extends OrderEvent{
  final DeliveryInfo deliveryInfo;
  ConfirmOrderEvent(this.deliveryInfo);
}