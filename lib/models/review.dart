class Review {
  final String? id;
  final String? experienceDescription;
  final int overallSatisfaction;
  final int itemQuality;
  final int communication;
  final int timeliness;
  final String valueForMoney;
  final int netPromoterScore;
  final bool willUseAgain;
  final String? orderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    this.id,
    this.experienceDescription,
    required this.overallSatisfaction,
    required this.itemQuality,
    required this.communication,
    required this.timeliness,
    required this.valueForMoney,
    required this.netPromoterScore,
    required this.willUseAgain,
    this.orderId,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String?,
      experienceDescription: json['experienceDescription'] as String?,
      overallSatisfaction: json['overallSatisfaction'] as int? ?? 0,
      itemQuality: json['itemQuality'] as int? ?? 0,
      communication: json['communication'] as int? ?? 0,
      timeliness: json['timeliness'] as int? ?? 0,
      valueForMoney: json['valueForMoney'] as String? ?? '',
      netPromoterScore: json['netPromoterScore'] as int? ?? 0,
      willUseAgain: json['willUseAgain'] as bool? ?? false,
      orderId: json['orderId'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Extract just the letter from valueForMoney (e.g., "A. قيمة ممتازة" -> "A")
    String cleanValueForMoney = valueForMoney;
    if (valueForMoney.isNotEmpty && valueForMoney.contains('.')) {
      cleanValueForMoney = valueForMoney.split('.')[0].trim();
    }
    
    return {
      if (id != null) 'id': id,
      if (experienceDescription != null) 'experienceDescription': experienceDescription,
      'overallSatisfaction': overallSatisfaction,
      'itemQuality': itemQuality,
      'communication': communication,
      'timeliness': timeliness,
      'valueForMoney': cleanValueForMoney,
      'netPromoterScore': netPromoterScore,
      'willUseAgain': willUseAgain,
      if (orderId != null) 'orderId': orderId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? experienceDescription,
    int? overallSatisfaction,
    int? itemQuality,
    int? communication,
    int? timeliness,
    String? valueForMoney,
    int? netPromoterScore,
    bool? willUseAgain,
    String? orderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      experienceDescription: experienceDescription ?? this.experienceDescription,
      overallSatisfaction: overallSatisfaction ?? this.overallSatisfaction,
      itemQuality: itemQuality ?? this.itemQuality,
      communication: communication ?? this.communication,
      timeliness: timeliness ?? this.timeliness,
      valueForMoney: valueForMoney ?? this.valueForMoney,
      netPromoterScore: netPromoterScore ?? this.netPromoterScore,
      willUseAgain: willUseAgain ?? this.willUseAgain,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 