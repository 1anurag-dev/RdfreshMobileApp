import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  final String userId;
  const LoadCart(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AddProductToCart extends CartEvent {
  final CartItem item;
  final String userId;
  const AddProductToCart(this.item, this.userId);
  @override
  List<Object?> get props => [item, userId];
}

class UpdateQuantity extends CartEvent {
  final String productId;
  final int newQuantity;
  final String userId;
  const UpdateQuantity(this.productId, this.newQuantity, this.userId);
  @override
  List<Object?> get props => [productId, newQuantity, userId];
}

// Internal event for stream updates
class CartUpdated extends CartEvent {
  final List<CartItem> items;
  const CartUpdated(this.items);
  @override
  List<Object?> get props => [items];
}

class CartErrorEvent extends CartEvent {
  final String message;
  const CartErrorEvent(this.message);
  @override
  List<Object?> get props => [message];
}

class ClearCartEvent extends CartEvent {
  final String userId;
  const ClearCartEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}
