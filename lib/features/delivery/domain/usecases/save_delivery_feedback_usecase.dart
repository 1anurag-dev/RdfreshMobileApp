import 'package:dartz/dartz.dart';
import '../repositories/delivery_feedback_repository.dart';

class SaveDeliveryFeedbackUseCase {
  final DeliveryFeedbackRepository repository;

  SaveDeliveryFeedbackUseCase(this.repository);

  Future<Either<String, void>> call({
    required String orderId,
    required String customerEmail,
    required int rating,
    required String feedback,
    required String signature,
    required Map<String, dynamic> orderDetails,
  }) {
    return repository.saveDeliveryFeedback(
      orderId: orderId,
      customerEmail: customerEmail,
      rating: rating,
      feedback: feedback,
      signature: signature,
      orderDetails: orderDetails,
    );
  }
}
