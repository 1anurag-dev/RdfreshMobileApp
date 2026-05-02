import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Stream<List<OrderModel>> getActiveOrders(String userEmail);
  Stream<OrderModel?> getOrderById(String orderId);
  Future<OrderModel> completeOrder({
    required String orderId,
    required String signature,
    int? rating,
    Map<String, dynamic>? feedback,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore firestore;

  OrderRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<OrderModel>> getActiveOrders(String userEmail) {
    return firestore
        .collection('orders')
        .where('customerEmail', isEqualTo: userEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  @override
  Stream<OrderModel?> getOrderById(String orderId) {
    return firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return OrderModel.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  @override
  Future<OrderModel> completeOrder({
    required String orderId,
    required String signature,
    int? rating,
    Map<String, dynamic>? feedback,
  }) async {
    try {
      final orderRef = firestore.collection('orders').doc(orderId);

      final orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        throw AuthException(code: 'order-not-found', message: 'Order not found');
      }

      await orderRef.update({
        'signature': signature,
        'signatureStatus': 'signed',
        'status': 'delivered',
        'feedback': feedback,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await orderRef.get();
      return OrderModel.fromFirestore(updatedDoc.data()!, updatedDoc.id);
    } catch (e) {
      throw AuthException(code: 'update-failed', message: e.toString());
    }
  }
}
