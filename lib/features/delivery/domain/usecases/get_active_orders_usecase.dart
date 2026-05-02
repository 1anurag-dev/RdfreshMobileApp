import 'package:dartz/dartz.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetActiveOrdersUseCase {
  final OrderRepository repository;

  GetActiveOrdersUseCase(this.repository);

  Stream<List<OrderEntity>> call(String userEmail) {
    return repository.getActiveOrders(userEmail);
  }
}
