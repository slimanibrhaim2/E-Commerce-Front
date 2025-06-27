import 'product.dart';

class CartItem {
  final String itemId;
  final String? imageUrl;
  final String name;
  final double price;
  final double totalPrice;
  final int quantity;

  CartItem({
    required this.itemId,
    this.imageUrl,
    required this.name,
    required this.price,
    required this.totalPrice,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['itemId'] as String,
      imageUrl: json['imageUrl'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'imageUrl': imageUrl,
      'name': name,
      'price': price,
      'totalPrice': totalPrice,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? itemId,
    String? imageUrl,
    String? name,
    double? price,
    double? totalPrice,
    int? quantity,
  }) {
    return CartItem(
      itemId: itemId ?? this.itemId,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      quantity: quantity ?? this.quantity,
    );
  }
} 