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
  ];

  bool get isDelivered => status == 'delivered';
  bool get needsSignature => signatureStatus != 'signed' && !isDelivered;
}
