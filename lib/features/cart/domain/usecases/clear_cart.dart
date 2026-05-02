import 'package:dartz/dartz.dart';
import '../repositories/cart_repository.dart';

class ClearCart {
  final CartRepository repository;

  ClearCart(this.repository);

  Future<Either<String, void>> call(String userId) async {
    return await repository.clearCart(userId);
  }
}
