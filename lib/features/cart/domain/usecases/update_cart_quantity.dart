import 'package:dartz/dartz.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantity {
  final CartRepository repository;

  UpdateCartItemQuantity(this.repository);

  Future<Either<String, void>> call(
    String userId,
    String productId,
    int quantity,
  ) {
    return repository.updateCartItemQuantity(userId, productId, quantity);
  }
}
