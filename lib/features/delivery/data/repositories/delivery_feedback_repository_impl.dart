import 'package:dartz/dartz.dart';
import '../../domain/repositories/delivery_feedback_repository.dart';
import '../datasources/delivery_feedback_remote_data_source.dart';

class DeliveryFeedbackRepositoryImpl implements DeliveryFeedbackRepository {
  final DeliveryFeedbackRemoteDataSource remoteDataSource;

  DeliveryFeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, void>> saveDeliveryFeedback({
    required String orderId,
    required String customerEmail,
    required int rating,
    required String feedback,
    required String signature,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      await remoteDataSource.saveDeliveryFeedback(
        orderId: orderId,
        customerEmail: customerEmail,
        rating: rating,
        feedback: feedback,
        signature: signature,
        orderDetails: orderDetails,
      );
      return const Right(null);
    } on FeedbackException catch (e) {
      return Left(e.message);
    } catch (e) {
      return const Left('Unable to save feedback. Please try again.');
    }
  }
}
