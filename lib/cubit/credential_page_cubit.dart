import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'credential_page_state.dart';

class CredentialPageCubit extends Cubit<CredentialPageState> {
  CredentialPageCubit() : super(LoginMode());

  void switchMode()
  {
    if(state is LoginMode)
    {
      emit(SignupMode());
    }
    else {
      emit(LoginMode());
    }
  }
}
