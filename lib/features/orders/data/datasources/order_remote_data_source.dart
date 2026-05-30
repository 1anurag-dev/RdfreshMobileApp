import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/order_model.dart';
import '../../../cart/data/models/cart_item_model.dart';

abstract class CheckoutOrderRemoteDataSource {
  Future<CheckoutOrderModel> createOrder(CheckoutOrderModel order);
  Future<CheckoutOrderModel> getOrder(String orderId);
  Future<void> updateOrder(CheckoutOrderModel order);
}

class CheckoutOrderRemoteDataSourceImpl
    implements CheckoutOrderRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  CheckoutOrderRemoteDataSourceImpl({
    required this.firestore,
    required this.functions,
  });

  static Map<String, dynamic> _deepCast(Map<Object?, Object?> raw) {
    return raw.map((key, value) => MapEntry(
          key.toString(),
          _deepCastValue(value),
        ));
  }

  static dynamic _deepCastValue(dynamic value) {
    if (value is Map) {
      return _deepCast(Map<Object?, Object?>.from(value));
    } else if (value is List) {
      return value.map(_deepCastValue).toList();
    }
    return value;
  }

  @override
  Future<CheckoutOrderModel> createOrder(CheckoutOrderModel order) async {
    try {
      final callable = functions.httpsCallable('createOrder');
      final result = await callable.call({
        'items': order.items
            .map((item) => (item as CartItemModel).toJson())
            .toList(),
        'billingInfo': (order.billingInfo as CheckoutBillingInfoModel).toJson(),
      });

      final data = _deepCast(Map<Object?, Object?>.from(result.data as Map));
      return CheckoutOrderModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<CheckoutOrderModel> getOrder(String orderId) async {
    try {
      final doc = await firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        throw Exception('Order not found');
      }

      final data = doc.data();
      if (data == null) {
        throw Exception('Order data is empty');
      }
      return CheckoutOrderModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<void> updateOrder(CheckoutOrderModel order) async {
    try {
      await firestore.collection('orders').doc(order.id).update(order.toJson());
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }
}
