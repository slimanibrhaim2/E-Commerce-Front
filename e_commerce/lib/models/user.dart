import 'package:meta/meta.dart';

class User {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String? profilePhoto;
  final String? description;

  User({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.profilePhoto,
    this.description,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePhoto': profilePhoto,
      'description': description,
    };
  }
} 