import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_feedback_model.dart';

class FeedbackException implements Exception {
  final String message;
  final String code;

  FeedbackException({required this.message, required this.code});
}

abstract class DeliveryFeedbackRemoteDataSource {
  Future<void> saveDeliveryFeedback({
    required String orderId,
    required String customerEmail,
    required int rating,
    required String feedback,
    required String signature,
    required Map<String, dynamic> orderDetails,
  });
}

class DeliveryFeedbackRemoteDataSourceImpl implements DeliveryFeedbackRemoteDataSource {
  final FirebaseFirestore firestore;

  DeliveryFeedbackRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> saveDeliveryFeedback({
    required String orderId,
    required String customerEmail,
    required int rating,
    required String feedback,
    required String signature,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      final feedbackData = DeliveryFeedbackModel(
        id: '${orderId}_${customerEmail}_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        customerEmail: customerEmail,
        rating: rating,
        feedback: feedback,
        signature: signature,
        completedAt: Timestamp.now(),
        orderDetails: orderDetails,
      );

      await firestore
          .collection('delivery_feedback')
          .doc(feedbackData.id)
          .set(feedbackData.toFirestore());
    } catch (e) {
      throw FeedbackException(code: 'save-feedback-failed', message: e.toString());
    }
  }
}
