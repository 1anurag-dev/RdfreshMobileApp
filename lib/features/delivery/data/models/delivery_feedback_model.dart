import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryFeedbackModel {
  final String id;
  final String orderId;
  final String customerEmail;
  final int rating;
  final String feedback;
  final String signature;
  final Timestamp completedAt;
  final Map<String, dynamic> orderDetails;

  DeliveryFeedbackModel({
    required this.id,
    required this.orderId,
    required this.customerEmail,
    required this.rating,
    required this.feedback,
    required this.signature,
    required this.completedAt,
    required this.orderDetails,
  });

  factory DeliveryFeedbackModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return DeliveryFeedbackModel(
      id: documentId,
      orderId: data['orderId'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      rating: data['rating'] ?? 0,
      feedback: data['feedback'] ?? '',
      signature: data['signature'] ?? '',
      completedAt: data['completedAt'] ?? Timestamp.now(),
      orderDetails: Map<String, dynamic>.from(data['orderDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'customerEmail': customerEmail,
      'rating': rating,
      'feedback': feedback,
      'signature': signature,
      'completedAt': completedAt,
      'orderDetails': orderDetails,
    };
  }

  DeliveryFeedbackModel copyWith({
    String? orderId,
    String? customerEmail,
    int? rating,
    String? feedback,
    String? signature,
    Timestamp? completedAt,
    Map<String, dynamic>? orderDetails,
  }) {
    return DeliveryFeedbackModel(
      id: id,
      orderId: orderId ?? this.orderId,
      customerEmail: customerEmail ?? this.customerEmail,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      signature: signature ?? this.signature,
      completedAt: completedAt ?? this.completedAt,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }
}
