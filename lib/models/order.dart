class Order {
  final String? id;
  final String? orderStatus;
  final double? totalAmount;
  final String? addressId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  Order({
    this.id,
    this.orderStatus,
    this.totalAmount,
    this.addressId,
    this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderStatus: json['orderStatus'] ?? json['statusName'],
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      addressId: json['addressId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      items: (json['items'] as List<dynamic>? ?? []).map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}

class OrderItem {
  final String? name;
  final String? imageUrl;
  final int? quantity;
  final double? price;
  final double? totalPrice;

  OrderItem({
    this.name,
    this.imageUrl,
    this.quantity,
    this.price,
    this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
      price: (json['price'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
    );
  }
} 