import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/complete_order_usecase.dart';
import '../../domain/usecases/get_active_orders_usecase.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetActiveOrdersUseCase getActiveOrders;
  final CompleteOrderUseCase completeOrder;
  final FirebaseAuth firebaseAuth;

  OrderBloc({
    required this.getActiveOrders,
    required this.completeOrder,
    required this.firebaseAuth,
  }) : super(OrderInitial()) {
    on<LoadActiveOrders>(_onLoadActiveOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<CompleteOrder>(_onCompleteOrder);
  }

  Future<void> _onLoadActiveOrders(
    LoadActiveOrders event,
    Emitter<OrderState> emit,
  ) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const OrderError('No authenticated user found'));
      return;
    }

    final userEmail = currentUser.email;
    if (userEmail == null) {
      emit(const OrderError('User email not available'));
      return;
    }

    emit(OrderLoading());
    try {
      await emit.forEach(
        getActiveOrders(userEmail),
        onData: (orders) {
          if (orders.isEmpty) {
            return const ActiveOrdersLoaded([]);
          }
          return ActiveOrdersLoaded(orders);
        },
        onError: (error, _) {
          return OrderError(error.toString());
        },
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser?.email == null) {
        emit(const OrderError('User email not available'));
        return;
      }

      final ordersStream = getActiveOrders(currentUser!.email!);
      await for (final orders in ordersStream) {
        final order = orders.firstWhere(
          (order) => order.orderId == event.orderId,
          orElse: () => throw Exception('Order not found'),
        );
        emit(OrderDetailsLoaded(order));
        break;
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCompleteOrder(
    CompleteOrder event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderDetailsLoaded) {
      emit(OrderCompletionLoading(currentState.order));

      try {
        final result = await completeOrder(
          orderId: event.orderId,
          signature: event.signature,
          rating: event.rating,
          feedback: event.feedback != null ? {
        'stars': event.rating,
        'text': event.feedback,
      } : null,
        );

        final completedOrder = await result.fold(
          (error) async {
            emit(OrderError(error));
            return null;
          },
          (order) async {
            return order;
          },
        );

        if (completedOrder != null) {
          emit(OrderCompleted(completedOrder));
        }
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    }
  }
}
