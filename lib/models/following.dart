class Following {
  final String? followingId;
  final String? followingName;
  final String? followingProfileUrl;
  final DateTime? createdAt;

  Following({
    this.followingId,
    this.followingName,
    this.followingProfileUrl,
    this.createdAt,
  });

  factory Following.fromJson(Map<String, dynamic> json) {
    return Following(
      followingId: json['followingId'] as String?,
      followingName: json['followingName'] as String?,
      followingProfileUrl: json['followingProfileUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followingId': followingId,
      'followingName': followingName,
      'followingProfileUrl': followingProfileUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Following copyWith({
    String? followingId,
    String? followingName,
    String? followingProfileUrl,
    DateTime? createdAt,
  }) {
    return Following(
      followingId: followingId ?? this.followingId,
      followingName: followingName ?? this.followingName,
      followingProfileUrl: followingProfileUrl ?? this.followingProfileUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 