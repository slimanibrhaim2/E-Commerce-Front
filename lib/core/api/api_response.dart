import '../../models/user.dart';

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? resultStatus;

  ApiResponse({
    this.data,
    this.message,
    this.success = true,
    this.resultStatus,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [T Function(dynamic)? fromJson]) {
    return ApiResponse(
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : json['data'] as T?,
      message: json['message'],
      success: json['success'] ?? true,
      resultStatus: json['resultStatus'] as int?,
    );
  }
}