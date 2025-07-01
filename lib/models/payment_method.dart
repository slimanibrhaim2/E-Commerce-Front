class PaymentMethod {
  final String? id;
  final String? name;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<dynamic> payments;

  PaymentMethod({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.payments,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      payments: json['payments'] as List<dynamic>? ?? [],
    );
  }
} 