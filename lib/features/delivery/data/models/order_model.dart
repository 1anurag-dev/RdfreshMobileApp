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
    super.signedAt,
    super.deliveredAt,
    super.bagChangeDeadline,
    super.remindersSent,
    super.lastReminderSentAt,
    super.escalated,
    super.escalatedAt,
  });

  static Map<String, dynamic>? _toStringDynamicMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  factory OrderModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final shipToData = _toStringDynamicMap(data['shipTo']);
    final billingInfo = _toStringDynamicMap(data['billingInfo']);
    final addressSource = shipToData ?? billingInfo;

    String createdAtStr;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      createdAtStr = rawCreatedAt.toDate().toIso8601String();
    } else if (rawCreatedAt is String) {
      createdAtStr = rawCreatedAt;
    } else {
      createdAtStr = DateTime.now().toIso8601String();
    }

    final customerName = addressSource != null
        ? '${addressSource['firstName'] ?? addressSource['name'] ?? ''} ${addressSource['lastName'] ?? ''}'.trim()
        : '';

    return OrderModel(
      orderId: (data['orderId'] ?? data['id'] ?? documentId).toString(),
      status: (data['status'] ?? 'pending').toString(),
      totalAmount: (data['total_amount'] ?? data['total'] ?? 0) as num,
      shipTo: ShipToAddress(
        name: (addressSource?['name'] ?? customerName).toString(),
        city: (addressSource?['city'] ?? '').toString(),
        state: (addressSource?['state'] ?? '').toString(),
        street1: (addressSource?['street1'] ?? addressSource?['address'] ?? '').toString(),
        phone: (addressSource?['phone'] ?? '').toString(),
      ),
      signature: data['signature']?.toString(),
      signatureStatus: data['signatureStatus']?.toString(),
      rating: data['rating'] is int ? data['rating'] as int : null,
      feedback: _parseFeedback(data['feedback']),
      customerEmail: (data['customerEmail'] ?? '').toString(),
      customerUsername: (data['customerUsername'] ?? customerName).toString(),
      orderDate: (data['orderDate'] ?? createdAtStr).toString(),
      createdAt: createdAtStr,
      signedAt: data['signedAt']?.toString(),
      deliveredAt: data['deliveredAt']?.toString(),
      bagChangeDeadline: data['bagChangeDeadline']?.toString(),
      remindersSent: (data['remindersSent'] as int?) ?? 0,
      lastReminderSentAt: data['lastReminderSentAt']?.toString(),
      escalated: (data['escalated'] as bool?) ?? false,
      escalatedAt: data['escalatedAt']?.toString(),
    );
  }

  // Helper method to parse feedback from both old (String) and new (Map) formats
  static Map<String, dynamic>? _parseFeedback(dynamic feedbackData) {
    if (feedbackData == null) return null;
    if (feedbackData is Map) {
      return Map<String, dynamic>.from(feedbackData);
    }
    if (feedbackData is String) {
      return {'stars': null, 'text': feedbackData};
    }
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
      'signedAt': signedAt,
      'deliveredAt': deliveredAt,
      'bagChangeDeadline': bagChangeDeadline,
      'remindersSent': remindersSent,
      'lastReminderSentAt': lastReminderSentAt,
      'escalated': escalated,
      'escalatedAt': escalatedAt,
    };
  }

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
      signedAt: signedAt,
      deliveredAt: deliveredAt,
      bagChangeDeadline: bagChangeDeadline,
      remindersSent: remindersSent,
      lastReminderSentAt: lastReminderSentAt,
      escalated: escalated,
      escalatedAt: escalatedAt,
    );
  }

  OrderModel copyWith({
    String? status,
    String? signature,
    String? signatureStatus,
    int? rating,
    Map<String, dynamic>? feedback,
    String? signedAt,
    String? deliveredAt,
    String? bagChangeDeadline,
    int? remindersSent,
    bool? escalated,
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
      signedAt: signedAt ?? this.signedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      bagChangeDeadline: bagChangeDeadline ?? this.bagChangeDeadline,
      remindersSent: remindersSent ?? this.remindersSent,
      lastReminderSentAt: lastReminderSentAt,
      escalated: escalated ?? this.escalated,
      escalatedAt: escalatedAt,
    );
  }
}
