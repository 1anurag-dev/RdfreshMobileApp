import 'package:dartz/dartz.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CompleteOrderUseCase {
  final OrderRepository repository;

  CompleteOrderUseCase(this.repository);

  Future<Either<String, OrderEntity>> call({
    required String orderId,
    required String signature,
    int? rating,
    Map<String, dynamic>? feedback,
  }) {
    return repository.completeOrder(
      orderId: orderId,
      signature: signature,
      rating: rating,
      feedback: feedback,
    );
  }
}
