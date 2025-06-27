import 'product.dart';

class Favorite {
  final String id;
  final String userId;
  final String baseItemId;
  final String itemId;
  final int quantity;
  final Product baseItem;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.baseItemId,
    required this.itemId,
    required this.quantity,
    required this.baseItem,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    // Create a modified baseItem with the quantity from the favorite
    final baseItemJson = json['baseItem'] ?? {};
    final baseItemWithQuantity = Map<String, dynamic>.from(baseItemJson);
    baseItemWithQuantity['stockQuantity'] = json['quantity'] ?? 0; // Use favorite quantity as stockQuantity
    
    return Favorite(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      baseItemId: json['baseItemId'] ?? '',
      itemId: json['itemId'] ?? '',
      quantity: json['quantity'] ?? 0,
      baseItem: Product.fromJson(baseItemWithQuantity),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'baseItemId': baseItemId,
    'itemId': itemId,
    'quantity': quantity,
    'baseItem': baseItem.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
} 