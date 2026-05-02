import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

abstract class CheckoutOrderState extends Equatable {
  const CheckoutOrderState();

  @override
  List<Object?> get props => [];
}

class CheckoutOrderInitial extends CheckoutOrderState {}

class CheckoutOrderLoading extends CheckoutOrderState {}

class CheckoutOrderSuccess extends CheckoutOrderState {
  final CheckoutOrder order;

  const CheckoutOrderSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class CheckoutOrderError extends CheckoutOrderState {
  final String message;

  const CheckoutOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
