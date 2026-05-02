import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item.dart';

class CheckoutOrder extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final CheckoutBillingInfo billingInfo;
  final double subtotal;
  final double tax;
  final double total;
  final String status; // pending, processing, completed, failed
  final DateTime createdAt;
  final String? quickbooksInvoiceId;
  final String? shipstationOrderId;
  final String? shipStationSyncStatus;
  final String? shipStationError;

  const CheckoutOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.billingInfo,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.quickbooksInvoiceId,
    this.shipstationOrderId,
    this.shipStationSyncStatus,
    this.shipStationError,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    items,
    billingInfo,
    subtotal,
    tax,
    total,
    status,
    createdAt,
    quickbooksInvoiceId,
    shipstationOrderId,
    shipStationSyncStatus,
    shipStationError,
  ];
}

class CheckoutBillingInfo extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zip;

  const CheckoutBillingInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    address,
    city,
    state,
    zip,
  ];
}
