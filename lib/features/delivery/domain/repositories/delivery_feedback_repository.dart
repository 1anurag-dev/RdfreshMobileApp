import 'package:dartz/dartz.dart';

abstract class DeliveryFeedbackRepository {
  Future<Either<String, void>> saveDeliveryFeedback({
    required String orderId,
    required String customerEmail,
    required int rating,
    required String feedback,
    required String signature,
    required Map<String, dynamic> orderDetails,
  });
}
