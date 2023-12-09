import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'add_remove_counter_state.dart';

class AddRemoveCounterCubit extends Cubit<AddRemoveCounterState> {
  AddRemoveCounterCubit([int init = 0]) : super(AddRemoveNewCounterState(count: init));

  void changeCounter(int count)
  {
    emit(AddRemoveNewCounterState(count: count));
  }
}
