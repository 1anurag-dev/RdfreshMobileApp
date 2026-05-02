import 'package:dartz/dartz.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<Product>>> getAllProducts() async {
    try {
      final remoteProducts = await remoteDataSource.getAllProducts();
      return Right(remoteProducts);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
