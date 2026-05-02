import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_order.dart';
import 'checkout_order_event.dart';
import 'checkout_order_state.dart';

class CheckoutOrderBloc extends Bloc<CheckoutOrderEvent, CheckoutOrderState> {
  final CreateCheckoutOrder createCheckoutOrder;

  CheckoutOrderBloc({required this.createCheckoutOrder})
    : super(CheckoutOrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<CheckoutOrderState> emit,
  ) async {
    emit(CheckoutOrderLoading());
    final result = await createCheckoutOrder(event.order);
    result.fold(
      (failure) => emit(CheckoutOrderError(failure.message)),
      (order) => emit(CheckoutOrderSuccess(order)),
    );
  }
}
