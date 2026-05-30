import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

class CheckoutOrderRepositoryImpl implements CheckoutOrderRepository {
  final CheckoutOrderRemoteDataSource remoteDataSource;

  CheckoutOrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CheckoutOrder>> createOrder(
    CheckoutOrder order,
  ) async {
    try {
      final orderModel = order as CheckoutOrderModel;
      final result = await remoteDataSource.createOrder(orderModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Unable to create order. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, CheckoutOrder>> getOrder(String orderId) async {
    try {
      final result = await remoteDataSource.getOrder(orderId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Unable to load order details. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrder(CheckoutOrder order) async {
    try {
      final orderModel = order as CheckoutOrderModel;
      await remoteDataSource.updateOrder(orderModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Unable to update order. Please try again.'));
    }
  }
}
