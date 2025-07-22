
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? resultStatus;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    this.data,
    this.message,
    this.success = true,
    this.resultStatus,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [T Function(dynamic)? fromJson]) {
    return ApiResponse(
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : json['data'] as T?,
      message: json['message'],
      success: json['success'] ?? true,
      resultStatus: json['resultStatus'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}