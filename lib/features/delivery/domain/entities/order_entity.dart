import 'package:equatable/equatable.dart';

class ShipToAddress extends Equatable {
  final String name;
  final String city;
  final String state;
  final String street1;
  final String phone;

  const ShipToAddress({
    required this.name,
    required this.city,
    required this.state,
    required this.street1,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, city, state, street1, phone];
}

class OrderEntity extends Equatable {
  final String orderId;
  final String status;
  final num totalAmount;
  final ShipToAddress shipTo;
  final String? signature;
  final String? signatureStatus;
  final int? rating;
  final Map<String, dynamic>? feedback;
  final String customerEmail;
  final String customerUsername;
  final String orderDate;
  final String createdAt;
  final String? signedAt;
  final String? deliveredAt;
  final String? bagChangeDeadline;
  final int remindersSent;
  final String? lastReminderSentAt;
  final bool escalated;
  final String? escalatedAt;

  const OrderEntity({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.shipTo,
    this.signature,
    this.signatureStatus,
    this.rating,
    this.feedback,
    required this.customerEmail,
    required this.customerUsername,
    required this.orderDate,
    required this.createdAt,
    this.signedAt,
    this.deliveredAt,
    this.bagChangeDeadline,
    this.remindersSent = 0,
    this.lastReminderSentAt,
    this.escalated = false,
    this.escalatedAt,
  });

  @override
  List<Object?> get props => [
    orderId,
    status,
    totalAmount,
    shipTo,
    signature,
    signatureStatus,
    rating,
    feedback,
    customerEmail,
    customerUsername,
    orderDate,
    createdAt,
    signedAt,
    deliveredAt,
    bagChangeDeadline,
    remindersSent,
    lastReminderSentAt,
    escalated,
    escalatedAt,
  ];

  bool get isDelivered => status.toLowerCase() == 'delivered';
  bool get needsBagChange =>
      isDelivered && signatureStatus != 'signed';

  int get daysSinceDelivery {
    if (deliveredAt == null) return 0;
    final delivered = DateTime.tryParse(deliveredAt!);
    if (delivered == null) return 0;
    return DateTime.now().difference(delivered).inDays;
  }
}
