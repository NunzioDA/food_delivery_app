part of 'delivery_info_cubit.dart';

@immutable
sealed class DeliveryInfoState {}

class DeliveryInfoStateFetched extends DeliveryInfoState{
  final List<DeliveryInfo> myDeliveryInfos;
  DeliveryInfoStateFetched({required this.myDeliveryInfos});
}

class DeliveryInfoSelectionChanged extends DeliveryInfoStateFetched{
  final DeliveryInfo? selected;
  DeliveryInfoSelectionChanged({
    required this.selected, 
    required super.myDeliveryInfos
  });
}

class DeliveryInfoError extends DeliveryInfoState{
  final String error;
  DeliveryInfoError({required this.error});
}
