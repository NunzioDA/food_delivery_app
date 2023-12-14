import 'package:bloc/bloc.dart';
import 'package:food_delivery_app/Communication/http_communication.dart';
import 'package:food_delivery_app/Data/Model/delivery_info.dart';
import 'package:food_delivery_app/Data/Model/order.dart';
import 'package:food_delivery_app/Data/Repositories/order_repository.dart';
import 'package:food_delivery_app/bloc/user_bloc.dart';
import 'package:meta/meta.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {

  final UserBloc _userBloc;
  final OrderRepository _orderRepository = OrderRepository();

  OrderBloc(this._userBloc) : super(OrderInitial()) {
    on<OrderEvent>((event, emit) async {
      switch(event)
      {        
        case ConfirmOrderEvent():
          FdaResponse response;
          
          try{
            response = await _orderRepository.confirmOrder(
              _userBloc.state as LoggedInState, 
              event.deliveryInfo
            );
          }
          catch (e){
            response = FdaResponse(false, e.toString());
          }

          if(response.successful)
          {
            emit(OrderPlaced());
          }
          else{
            emit(OrderError(
              response.body,
              event, 
            ));
          }
          
          break;
        case FetchMyOrders():
        case FetchReceivedOrders():
            try{
              List<Order> myOrders;
              if(event is FetchMyOrders)
              {
                myOrders = await _orderRepository
                .fetchMyOrders(_userBloc.state as LoggedInState);
              }
              else{
                myOrders = await _orderRepository
                .fetchReceivedOrders(_userBloc.state as LoggedInState);
              }              

              emit(OrdersFetched(myOrders));
            }
            catch(e){              
              emit(OrderError(e.toString(), event));
            }
          break;

        
        case UpdateOrder():
          try{
            List<Order> myOrders = await _orderRepository.updateOrder(
              _userBloc.state as LoggedInState,
              event.order,
              event.newStatus
            );
            emit(OrderUpdated(myOrders));
          }
          catch(e)
          {
            emit(OrderError(e.toString(), event));
          }
          break;
      }
    });
  }
}
