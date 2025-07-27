class Following {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Following({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Following.fromJson(Map<String, dynamic> json) {
    return Following(
      id: json['id'] ?? '',
      followerId: json['followerId'] ?? '',
      followingId: json['followingId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'followerId': followerId,
    'followingId': followingId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  Following copyWith({
    String? id,
    String? followerId,
    String? followingId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Following(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
} 