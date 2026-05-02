import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class ActiveOrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const ActiveOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailsLoaded extends OrderState {
  final OrderEntity order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCompletionLoading extends OrderState {
  final OrderEntity order;

  const OrderCompletionLoading(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCompleted extends OrderState {
  final OrderEntity order;

  const OrderCompleted(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
