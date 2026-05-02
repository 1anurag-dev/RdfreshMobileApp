import 'package:dartz/dartz.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class AddToCart {
  final CartRepository repository;

  AddToCart(this.repository);

  Future<Either<String, void>> call(String userId, CartItem item) {
    return repository.addToCart(userId, item);
  }
}
