import 'package:meta/meta.dart';

class User {
  final String? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? phoneNumber;
  final String? email;
  final String? profilePhoto;
  final String? description;

  User({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.phoneNumber,
    this.email,
    this.profilePhoto,
    this.description,
  });

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
    };
  }
}

// profilePhoto: should be a URL string or a base64-encoded image string, depending on backend support. 