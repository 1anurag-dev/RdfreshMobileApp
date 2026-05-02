import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.status,
    required super.totalAmount,
    required super.shipTo,
    super.signature,
    super.signatureStatus,
    super.rating,
    super.feedback,
    required super.customerEmail,
    required super.customerUsername,
    required super.orderDate,
    required super.createdAt,
  });

  factory OrderModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final shipToData = data['shipTo'] as Map<String, dynamic>? ?? {};
    final timestamp = data['createdAt'] as Timestamp?;

    return OrderModel(
      orderId: data['orderId'] ?? documentId,
      status: data['status'] as String? ?? 'pending',
      totalAmount: data['total_amount'] as num? ?? 0,
      shipTo: ShipToAddress(
        name: shipToData['name'] as String? ?? '',
        city: shipToData['city'] as String? ?? '',
        state: shipToData['state'] as String? ?? '',
        street1: shipToData['street1'] as String? ?? '',
        phone: shipToData['phone'] as String? ?? '',
      ),
      signature: data['signature'] as String?,
      signatureStatus: data['signatureStatus'] as String?,
      rating: data['rating'] as int?,
      feedback: _parseFeedback(data['feedback']),
      customerEmail: data['customerEmail'] as String? ?? '',
      customerUsername: data['customerUsername'] as String? ?? '',
      orderDate: data['orderDate'] as String? ?? '',
      createdAt:
          timestamp?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    );
  }

  // Helper method to parse feedback from both old (String) and new (Map) formats
  static Map<String, dynamic>? _parseFeedback(dynamic feedbackData) {
    if (feedbackData == null) return null;

    if (feedbackData is Map<String, dynamic>) {
      // New format: already a map with 'stars' and 'text'
      return feedbackData;
    }

    if (feedbackData is String) {
      // Old format: just a string, convert to new map format
      return {
        'stars': null, // No rating in old format
        'text': feedbackData,
      };
    }

    // Unknown format, return null
    return null;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'status': status,
      'total_amount': totalAmount,
      'shipTo': {
        'name': shipTo.name,
        'city': shipTo.city,
        'state': shipTo.state,
        'street1': shipTo.street1,
        'phone': shipTo.phone,
      },
      'signature': signature,
      'signatureStatus': signatureStatus,
      'rating': rating,
      'feedback': feedback,
      'customerEmail': customerEmail,
      'customerUsername': customerUsername,
      'orderDate': orderDate,
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse(createdAt).millisecondsSinceEpoch,
      ),
    };
  }

  // Add toEntity method
  OrderEntity toEntity() {
    return OrderEntity(
      orderId: orderId,
      status: status,
      totalAmount: totalAmount,
      shipTo: shipTo,
      signature: signature,
      signatureStatus: signatureStatus,
      rating: rating,
      feedback: feedback,
      customerEmail: customerEmail,
      customerUsername: customerUsername,
      orderDate: orderDate,
      createdAt: createdAt,
    );
  }

  OrderModel copyWith({
    String? status,
    String? signature,
    String? signatureStatus,
    int? rating,
    Map<String, dynamic>? feedback,
  }) {
    return OrderModel(
      orderId: orderId,
      status: status ?? this.status,
      totalAmount: totalAmount,
      shipTo: shipTo,
      signature: signature ?? this.signature,
      signatureStatus: signatureStatus ?? this.signatureStatus,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      customerEmail: customerEmail,
      customerUsername: customerUsername,
      orderDate: orderDate,
      createdAt: createdAt,
    );
  }
}
