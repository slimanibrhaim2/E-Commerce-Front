class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String sku;
  final int stockQuantity;
  final bool isAvailable;
  final String categoryId;
  final List<Media> media;
  final List<Feature> features;

  // Optional UI-only fields
  final String? imageUrl;
  final String? category;
  bool isFavorite;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.sku,
    required this.stockQuantity,
    required this.isAvailable,
    required this.categoryId,
    required this.media,
    required this.features,
    this.imageUrl,
    this.category,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      sku: json['sku'],
      stockQuantity: json['stockQuantity'],
      isAvailable: json['isAvailable'],
      categoryId: json['categoryId'],
      media: (json['media'] as List?)
          ?.map((m) => Media.fromJson(m))
          .toList() ?? [],
      features: (json['features'] as List?)
          ?.map((f) => Feature.fromJson(f))
          .toList() ?? [],
      imageUrl: json['imageUrl'], // Optional
      category: json['category'], // Optional
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'sku': sku,
    'stockQuantity': stockQuantity,
    'isAvailable': isAvailable,
    'categoryId': categoryId,
    'media': media.map((m) => m.toJson()).toList(),
    'features': features.map((f) => f.toJson()).toList(),
  };

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? sku,
    int? stockQuantity,
    bool? isAvailable,
    String? categoryId,
    List<Media>? media,
    List<Feature>? features,
    String? imageUrl,
    String? category,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId ?? this.categoryId,
      media: media ?? this.media,
      features: features ?? this.features,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}


class Media {
  final String url;
  final String mediaTypeId;

  Media({required this.url, required this.mediaTypeId});

  Map<String, dynamic> toJson() => {
    'url': url,
    'mediaTypeId': mediaTypeId,
  };

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    url: json['url'],
    mediaTypeId: json['mediaTypeId'],
  );
}

class Feature {
  final String? id;
  final String name;
  final String value;
  final String? productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Feature({
    this.id,
    required this.name,
    required this.value,
    this.productId,
    this.createdAt,
    this.updatedAt,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      name: json['name'],
      value: json['value'],
      productId: json['productId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'value': value,
    if (productId != null) 'productId': productId,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  Feature copyWith({
    String? id,
    String? name,
    String? value,
    String? productId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feature(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
