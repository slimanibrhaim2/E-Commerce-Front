import 'user.dart';

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  ApiResponse({
    this.data,
    this.message,
    this.success = true,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse(
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
      success: json['success'] ?? true,
    );
  }
} 