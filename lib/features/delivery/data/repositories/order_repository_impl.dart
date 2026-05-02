import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<OrderEntity>> getActiveOrders(String userEmail) {
    return remoteDataSource
        .getActiveOrders(userEmail)
        .map((orderModels) => orderModels
            .map((orderModel) => orderModel.toEntity())
            .toList());
  }

  @override
  Stream<OrderEntity?> getOrderById(String orderId) {
    return remoteDataSource.getOrderById(orderId).map((order) => order as OrderEntity?);
  }

  @override
  Future<Either<String, OrderEntity>> completeOrder({
    required String orderId,
    required String signature,
    int? rating,
    Map<String, dynamic>? feedback,
  }) async {
    try {
      final order = await remoteDataSource.completeOrder(
        orderId: orderId,
        signature: signature,
        rating: rating,
        feedback: feedback,
      );
      return Right(order);
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
