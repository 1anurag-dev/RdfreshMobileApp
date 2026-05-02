import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items;
  final String? errorMessage;
  final double totalAmount;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.totalAmount = 0.0,
  });

  int getQuantity(String productId) {
    try {
      final item = items.firstWhere(
        (element) => element.productId == productId,
      );
      return item.quantity;
    } catch (_) {
      return 0;
    }
  }

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    String? errorMessage,
    double? totalAmount,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, totalAmount];
}
