class User {
  final String? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? phoneNumber;
  final String? email;
  final String? profilePhoto;
  final String? description;
  final double? rating;
  final int? numOfReviews;
  final bool? isFollowing;

  User({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.phoneNumber,
    this.email,
    this.profilePhoto,
    this.description,
    this.rating,
    this.numOfReviews,
    this.isFollowing,
  });

  User copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? profilePhoto,
    String? description,
    double? rating,
    int? numOfReviews,
    bool? isFollowing,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      numOfReviews: numOfReviews ?? this.numOfReviews,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      numOfReviews: json['numOfReviews'] as int?,
      isFollowing: json['isFollowing'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (firstName != null) 'firstName': firstName,
      if (middleName != null) 'middleName': middleName,
      if (lastName != null) 'lastName': lastName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (numOfReviews != null) 'numOfReviews': numOfReviews,
      if (isFollowing != null) 'isFollowing': isFollowing,
    };
  }

  // Helper method to get full name
  String get fullName {
    final parts = <String>[];
    if (firstName?.isNotEmpty == true) parts.add(firstName!);
    if (middleName?.isNotEmpty == true) parts.add(middleName!);
    if (lastName?.isNotEmpty == true) parts.add(lastName!);
    return parts.isEmpty ? 'مستخدم' : parts.join(' ');
  }
}

// profilePhoto: should be a URL string or a base64-encoded image string, depending on backend support. 