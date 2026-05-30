import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String sku;
  final String imageUrl;
  final bool isAvailable;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.sku,
    required this.imageUrl,
    this.isAvailable = true,
    this.category = '',
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    sku,
    imageUrl,
    isAvailable,
    category,
  ];
}
