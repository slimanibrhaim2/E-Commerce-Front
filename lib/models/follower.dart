class Follower {
  final String? followerId;
  final String? followerName;
  final String? followerProfileUrl;
  final DateTime? createdAt;

  Follower({
    this.followerId,
    this.followerName,
    this.followerProfileUrl,
    this.createdAt,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      followerId: json['followerId'] as String?,
      followerName: json['followerName'] as String?,
      followerProfileUrl: json['followerProfileUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followerId': followerId,
      'followerName': followerName,
      'followerProfileUrl': followerProfileUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Follower copyWith({
    String? followerId,
    String? followerName,
    String? followerProfileUrl,
    DateTime? createdAt,
  }) {
    return Follower(
      followerId: followerId ?? this.followerId,
      followerName: followerName ?? this.followerName,
      followerProfileUrl: followerProfileUrl ?? this.followerProfileUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 