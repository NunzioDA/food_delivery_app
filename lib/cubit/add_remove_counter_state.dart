part of 'add_remove_counter_cubit.dart';

@immutable
sealed class AddRemoveCounterState {}

class AddRemoveNewCounterState extends AddRemoveCounterState{
  final int count;
  AddRemoveNewCounterState({required this.count});
}
