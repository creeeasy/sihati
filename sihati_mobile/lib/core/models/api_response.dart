/// Generic API response wrapper
/// Wraps all API responses with success/error status
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  // Create from JSON with custom parser for data
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'statusCode': statusCode,
    };
  }

  // Helper: Check if response has data
  bool get hasData => data != null;

  // Helper: Check if response has error message
  bool get hasError => !success || message != null;

  // Helper: Get error message or default
  String get errorMessage => message ?? 'Une erreur est survenue';

  // Named constructors for common scenarios
  factory ApiResponse.success({
    required T data,
    String? message,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode ?? 500,
    );
  }

  factory ApiResponse.loading() {
    return ApiResponse<T>(
      success: false,
      message: 'Chargement...',
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, hasData: $hasData, message: $message)';
  }
}
