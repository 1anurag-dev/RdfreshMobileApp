import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Stream<List<CartItemModel>> getCartItems(String userId);
  Future<void> addToCart(String userId, CartItemModel item);
  Future<void> updateCartItemQuantity(
    String userId,
    String productId,
    int quantity,
  );
  Future<void> removeFromCart(String userId, String productId);
  Future<void> clearCart(String userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore firestore;

  CartRemoteDataSourceImpl({required this.firestore});

  DocumentReference _cartRef(String userId) {
    return firestore.collection('carts').doc(userId);
  }

  @override
  Stream<List<CartItemModel>> getCartItems(String userId) {
    return _cartRef(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data() as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<void> addToCart(String userId, CartItemModel item) async {
    final ref = _cartRef(userId);

    // Using transaction to ensure atomic read-modify-write
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        transaction.set(ref, {
          'items': [item.toJson()],
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        var items =
            (data['items'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        final index = items.indexWhere((i) => i['productId'] == item.productId);

        if (index != -1) {
          // Update existing item: increment quantity
          final currentQuantity = items[index]['quantity'] as int? ?? 0;
          items[index]['quantity'] = currentQuantity + item.quantity;
          items[index]['updatedAt'] = DateTime.now().toIso8601String();
        } else {
          // Add new item
          final newItemJson = item.toJson();
          // Ensure addedAt is set for new items
          if (!newItemJson.containsKey('addedAt')) {
            newItemJson['addedAt'] = DateTime.now().toIso8601String();
          }
          items.add(newItemJson);
        }

        transaction.update(ref, {
          'items': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> updateCartItemQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      return removeFromCart(userId, productId);
    }

    final ref = _cartRef(userId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return; // Should not happen if updating

      final data = snapshot.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final index = items.indexWhere((i) => i['productId'] == productId);

      if (index != -1) {
        items[index]['quantity'] = quantity;
        items[index]['updatedAt'] = DateTime.now().toIso8601String();

        transaction.update(ref, {
          'items': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> removeFromCart(String userId, String productId) async {
    final ref = _cartRef(userId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final initialLength = items.length;
      items.removeWhere((item) => item['productId'] == productId);

      if (items.length != initialLength) {
        transaction.update(ref, {
          'items': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> clearCart(String userId) async {
    await _cartRef(userId).delete();
  }
}
