import 'package:bloc/bloc.dart';
import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/Data/Repositories/delivery_info_repository.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:meta/meta.dart';

part 'delivery_info_state.dart';

class DeliveryInfoCubit extends Cubit<DeliveryInfoState> {
  final UserBloc _userBloc;
  final DeliveryInfoRepository repository = DeliveryInfoRepository();
  DeliveryInfoCubit(this._userBloc) : super(DeliveryInfoStateFetched(myDeliveryInfos: const []));

  void selectDeliveryInfo(DeliveryInfo? deliveryInfo)
  {
    emit(DeliveryInfoSelectionChanged(
      selected: deliveryInfo,
      myDeliveryInfos: (state as DeliveryInfoStateFetched).myDeliveryInfos
    ));
  }

  void fetchDeliveryInfos() async
  {
    try{
      List<DeliveryInfo> infos = await repository.fetchMyDeliveryInfos(
        _userBloc.state as LoggedInState
      );
      emit(DeliveryInfoStateFetched(myDeliveryInfos: infos));
    }
    catch(e)
    {
      emit(DeliveryInfoError(error: e.toString()));
    }
    
  }
}
