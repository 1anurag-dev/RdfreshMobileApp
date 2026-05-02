import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final querySnapshot = await firestore
          .collection('products')
          .where('visibility', isEqualTo: 'customer')
          .get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}
