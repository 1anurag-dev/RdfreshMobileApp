import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

abstract class CheckoutOrderEvent extends Equatable {
  const CheckoutOrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends CheckoutOrderEvent {
  final CheckoutOrderModel order;

  const CreateOrderEvent(this.order);

  @override
  List<Object?> get props => [order];
}
