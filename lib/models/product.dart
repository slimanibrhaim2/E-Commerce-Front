class Media {
  final String url;
  final String mediaTypeId;

  Media({required this.url, required this.mediaTypeId});

  Map<String, dynamic> toJson() => {
    'url': url,
    'mediaTypeId': mediaTypeId,
  };
}

class Feature {
  final String name;
  final String value;

  Feature({required this.name, required this.value});

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
  };
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  bool isFavorite;
  final String userId;
  final String sku;
  final int stockQuantity;
  final bool isAvailable;
  final String categoryId;
  final List<Media> media;
  final List<Feature> features;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
    required this.userId,
    required this.sku,
    required this.stockQuantity,
    required this.isAvailable,
    required this.categoryId,
    required this.media,
    required this.features,
  });

// Factory constructor for creating Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(), // Ensures `price` is a double
      imageUrl: json['image'],
      category: json['category'],
      userId: json['userId'],
      sku: json['sku'],
      stockQuantity: json['stockQuantity'],
      isAvailable: json['isAvailable'],
      categoryId: json['categoryId'],
      media: List<Media>.from(json['media'].map((m) => Media(url: m['url'], mediaTypeId: m['mediaTypeId']))),
      features: List<Feature>.from(json['features'].map((f) => Feature(name: f['name'], value: f['value']))),
    );
  }

  Map<String, dynamic> toJson() => {
      'id': id,
    'name': name,
      'description': description,
      'price': price,
    'imageUrl': imageUrl,
      'category': category,
    'isFavorite': isFavorite,
    'userId': userId,
    'sku': sku,
    'stockQuantity': stockQuantity,
    'isAvailable': isAvailable,
    'categoryId': categoryId,
    'media': media.map((m) => m.toJson()).toList(),
    'features': features.map((f) => f.toJson()).toList(),
    };

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isFavorite,
    String? userId,
    String? sku,
    int? stockQuantity,
    bool? isAvailable,
    String? categoryId,
    List<Media>? media,
    List<Feature>? features,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId ?? this.userId,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId ?? this.categoryId,
      media: media ?? this.media,
      features: features ?? this.features,
    );
  }
} 