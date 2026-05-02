import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateCheckoutOrder {
  final CheckoutOrderRepository repository;

  CreateCheckoutOrder(this.repository);

  Future<Either<Failure, CheckoutOrder>> call(CheckoutOrder order) async {
    return await repository.createOrder(order);
  }
}
