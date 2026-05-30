import 'package:dartz/dartz.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<CartItem>> getCartItems(String userId) {
    return remoteDataSource
        .getCartItems(userId)
        .map((models) => models.cast<CartItem>());
  }

  @override
  Future<Either<String, void>> addToCart(String userId, CartItem item) async {
    try {
      await remoteDataSource.addToCart(userId, CartItemModel.fromEntity(item));
      return const Right(null);
    } catch (e) {
      return const Left('Unable to add item to cart. Please try again.');
    }
  }

  @override
  Future<Either<String, void>> updateCartItemQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      await remoteDataSource.updateCartItemQuantity(
        userId,
        productId,
        quantity,
      );
      return const Right(null);
    } catch (e) {
      return const Left('Unable to update cart. Please try again.');
    }
  }

  @override
  Future<Either<String, void>> removeFromCart(
    String userId,
    String productId,
  ) async {
    try {
      await remoteDataSource.removeFromCart(userId, productId);
      return const Right(null);
    } catch (e) {
      return const Left('Unable to remove item from cart. Please try again.');
    }
  }

  @override
  Future<Either<String, void>> clearCart(String userId) async {
    try {
      await remoteDataSource.clearCart(userId);
      return const Right(null);
    } catch (e) {
      return const Left('Unable to clear cart. Please try again.');
    }
  }
}
