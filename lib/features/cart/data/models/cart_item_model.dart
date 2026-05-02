import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.sku,
    required super.name,
    required super.price,
    required super.imageUrl,
    super.quantity,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      productId: data['productId'] ?? '',
      sku: data['sku'] ?? '',
      name: data['productName'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['image'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  factory CartItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel.fromMap(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'sku': sku,
      'productName': name,
      'price': price,
      'image': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      productId: item.productId,
      sku: item.sku,
      name: item.name,
      price: item.price,
      imageUrl: item.imageUrl,
      quantity: item.quantity,
    );
  }
}
