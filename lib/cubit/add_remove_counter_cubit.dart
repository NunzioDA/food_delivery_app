import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'add_remove_counter_state.dart';

class AddRemoveCounterCubit extends Cubit<AddRemoveCounterState> {
  AddRemoveCounterCubit() : super(AddRemoveNewCounterState(count: 0));

  void changeCounter(int count)
  {
    emit(AddRemoveNewCounterState(count: count));
  }
}
