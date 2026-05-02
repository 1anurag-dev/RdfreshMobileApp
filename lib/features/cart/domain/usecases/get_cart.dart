import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCart {
  final CartRepository repository;

  GetCart(this.repository);

  Stream<List<CartItem>> call(String userId) {
    return repository.getCartItems(userId);
  }
}
