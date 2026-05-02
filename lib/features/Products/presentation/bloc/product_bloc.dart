import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProducts getAllProducts;

  ProductBloc({required this.getAllProducts}) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      final result = await getAllProducts();
      result.fold(
        (failure) => emit(ProductError(message: failure)),
        (products) => emit(ProductLoaded(products: products)),
      );
    });
  }
}
