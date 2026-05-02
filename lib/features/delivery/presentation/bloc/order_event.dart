import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveOrders extends OrderEvent {}

class LoadOrderDetails extends OrderEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CompleteOrder extends OrderEvent {
  final String orderId;
  final String signature;
  final int? rating;
  final String? feedback;

  const CompleteOrder({
    required this.orderId,
    required this.signature,
    this.rating,
    this.feedback,
  });

  @override
  List<Object?> get props => [orderId, signature, rating, feedback];
}
