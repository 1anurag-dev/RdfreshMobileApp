import 'package:dartz/dartz.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Stream<List<CartItem>> getCartItems(String userId);
  Future<Either<String, void>> addToCart(String userId, CartItem item);
  Future<Either<String, void>> updateCartItemQuantity(
    String userId,
    String productId,
    int quantity,
  );
  Future<Either<String, void>> removeFromCart(String userId, String productId);
  Future<Either<String, void>> clearCart(String userId);
}
