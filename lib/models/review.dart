class Review {
  final String? id;
  final String? experienceDescription;
  final int? overallSatisfaction;
  final int? itemQuality;
  final int? communication;
  final int? timeliness;
  final String? valueForMoney;
  final int? netPromoterScore;
  final bool? willUseAgain;
  final double? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? providerId;
  final String? reviewerId;
  final String? orderId;

  const Review({
    this.id,
    this.experienceDescription,
    this.overallSatisfaction,
    this.itemQuality,
    this.communication,
    this.timeliness,
    this.valueForMoney,
    this.netPromoterScore,
    this.willUseAgain,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.providerId,
    this.reviewerId,
    this.orderId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String?,
      experienceDescription: json['experienceDescription'] as String?,
      overallSatisfaction: json['overallSatisfaction'] as int?,
      itemQuality: json['itemQuality'] as int?,
      communication: json['communication'] as int?,
      timeliness: json['timeliness'] as int?,
      valueForMoney: json['valueForMoney'] as String?,
      netPromoterScore: json['netPromoterScore'] as int?,
      willUseAgain: json['willUseAgain'] as bool?,
      rating: json['rating']?.toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      providerId: json['providerId'] as String?,
      reviewerId: json['reviewerId'] as String?,
      orderId: json['orderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experienceDescription': experienceDescription,
      'overallSatisfaction': overallSatisfaction,
      'itemQuality': itemQuality,
      'communication': communication,
      'timeliness': timeliness,
      'valueForMoney': valueForMoney,
      'netPromoterScore': netPromoterScore,
      'willUseAgain': willUseAgain,
      'rating': rating,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'providerId': providerId,
      'reviewerId': reviewerId,
      'orderId': orderId,
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
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? providerId,
    String? reviewerId,
    String? orderId,
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
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      providerId: providerId ?? this.providerId,
      reviewerId: reviewerId ?? this.reviewerId,
      orderId: orderId ?? this.orderId,
    );
  }
} 