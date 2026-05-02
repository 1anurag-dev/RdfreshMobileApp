import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';

class CheckoutOrderModel extends CheckoutOrder {
  const CheckoutOrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.billingInfo,
    required super.subtotal,
    required super.tax,
    required super.total,
    required super.status,
    required super.createdAt,
    super.quickbooksInvoiceId,
    super.shipstationOrderId,
    super.shipStationSyncStatus,
    super.shipStationError,
  });

  factory CheckoutOrderModel.fromJson(Map<String, dynamic> json) {
    return CheckoutOrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      billingInfo: CheckoutBillingInfoModel.fromJson(
        json['billingInfo'] as Map<String, dynamic>,
      ),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      quickbooksInvoiceId: json['quickbooksInvoiceId'] as String?,
      shipstationOrderId: json['shipstationOrderId'] as String?,
      shipStationSyncStatus: json['shipStationSyncStatus'] as String?,
      shipStationError: json['shipStationError'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => (item as CartItemModel).toJson()).toList(),
      'billingInfo': (billingInfo as CheckoutBillingInfoModel).toJson(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'quickbooksInvoiceId': quickbooksInvoiceId,
      'shipstationOrderId': shipstationOrderId,
      'shipStationSyncStatus': shipStationSyncStatus,
      'shipStationError': shipStationError,
    };
  }

  CheckoutOrderModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    CheckoutBillingInfoModel? billingInfo,
    double? subtotal,
    double? tax,
    double? total,
    String? status,
    DateTime? createdAt,
    String? quickbooksInvoiceId,
    String? shipstationOrderId,
    String? shipStationSyncStatus,
    String? shipStationError,
  }) {
    return CheckoutOrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      billingInfo:
          billingInfo ?? (this.billingInfo as CheckoutBillingInfoModel),
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      quickbooksInvoiceId: quickbooksInvoiceId ?? this.quickbooksInvoiceId,
      shipstationOrderId: shipstationOrderId ?? this.shipstationOrderId,
      shipStationSyncStatus:
          shipStationSyncStatus ?? this.shipStationSyncStatus,
      shipStationError: shipStationError ?? this.shipStationError,
    );
  }
}

class CheckoutBillingInfoModel extends CheckoutBillingInfo {
  const CheckoutBillingInfoModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.address,
    required super.city,
    required super.state,
    required super.zip,
  });

  factory CheckoutBillingInfoModel.fromJson(Map<String, dynamic> json) {
    return CheckoutBillingInfoModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zip: json['zip'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
    };
  }
}
