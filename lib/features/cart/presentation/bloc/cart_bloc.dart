import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/get_cart.dart';
import '../../domain/usecases/update_cart_quantity.dart';
import '../../domain/usecases/clear_cart.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCart getCart;
  final AddToCart addToCart;
  final UpdateCartItemQuantity updateCartItemQuantity;
  final ClearCart clearCart;
  StreamSubscription? _cartSubscription;

  CartBloc({
    required this.getCart,
    required this.addToCart,
    required this.updateCartItemQuantity,
    required this.clearCart,
  }) : super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddProductToCart>(_onAddProductToCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<CartUpdated>(_onCartUpdated);
    on<CartErrorEvent>(_onCartError);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await clearCart(event.userId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure)),
      (
        _,
      ) {}, // Success handled by stream update (which will likely emit an empty list)
    );
  }

  void _onCartError(CartErrorEvent event, Emitter<CartState> emit) {
    emit(
      state.copyWith(status: CartStatus.failure, errorMessage: event.message),
    );
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    await _cartSubscription?.cancel();
    _cartSubscription = getCart(event.userId).listen(
      (items) {
        add(CartUpdated(items));
      },
      onError: (error) {
        add(CartErrorEvent(error.toString()));
      },
    );
  }

  void _onCartUpdated(CartUpdated event, Emitter<CartState> emit) {
    final total = event.items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    emit(
      state.copyWith(
        status: CartStatus.success,
        items: event.items,
        totalAmount: total,
      ),
    );
  }

  Future<void> _onAddProductToCart(
    AddProductToCart event,
    Emitter<CartState> emit,
  ) async {
    final result = await addToCart(event.userId, event.item);
    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: failure),
      ), // Usually snackbar handles this
      (_) {}, // Success handled by stream update
    );
  }

  Future<void> _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<CartState> emit,
  ) async {
    final result = await updateCartItemQuantity(
      event.userId,
      event.productId,
      event.newQuantity,
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure)),
      (_) {},
    );
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}
