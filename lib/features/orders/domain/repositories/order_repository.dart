import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class CheckoutOrderRepository {
  Future<Either<Failure, CheckoutOrder>> createOrder(CheckoutOrder order);
  Future<Either<Failure, CheckoutOrder>> getOrder(String orderId);
  Future<Either<Failure, void>> updateOrder(CheckoutOrder order);
}
