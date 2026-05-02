import 'package:dartz/dartz.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Stream<List<OrderEntity>> getActiveOrders(String userEmail);
  Stream<OrderEntity?> getOrderById(String orderId);
  Future<Either<String, OrderEntity>> completeOrder({
    required String orderId,
    required String signature,
    int? rating,
    Map<String, dynamic>? feedback,
  });
}
