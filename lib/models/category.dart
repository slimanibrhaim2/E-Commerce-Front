class Category {
  final String id;
  final String name;
  final String description;
  final String? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Category>? subCategories;
  final bool isActive;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.subCategories,
    required this.isActive,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] ?? '',
      parentId: json['parentId'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      subCategories: (json['subCategories'] as List?)?.map((e) => Category.fromJson(e)).toList(),
      isActive: json['isActive'] ?? false,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parentId': parentId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'subCategories': subCategories?.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Category>? subCategories,
    bool? isActive,
    String? imageUrl,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subCategories: subCategories ?? this.subCategories,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
