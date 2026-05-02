import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String notifyTo;
  final String type;
  final String createdAt;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.notifyTo,
    required this.type,
    required this.createdAt,
    this.data,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        notifyTo,
        type,
        createdAt,
        data,
      ];

  bool get isOrderDelivery => type == 'order_delivery';
  
  String? get orderId => data?['orderId'] as String?;
}
