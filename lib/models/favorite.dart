import 'product.dart';

class Favorite {
  final String id;
  final String userId;
  final String baseItemId;
  final Product baseItem;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.baseItemId,
    required this.baseItem,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      baseItemId: json['baseItemId'] ?? '',
      baseItem: Product.fromJson(json['baseItem'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'baseItemId': baseItemId,
    'baseItem': baseItem.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
} 