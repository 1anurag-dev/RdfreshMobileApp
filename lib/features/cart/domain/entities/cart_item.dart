import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String productId;
  final String sku;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.sku,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? productId,
    String? sku,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [productId, sku, name, price, imageUrl, quantity];
}
