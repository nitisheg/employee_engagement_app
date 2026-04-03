import 'pagination_meta.dart';

/// Generic wrapper for every API response.
///
/// Usage:
/// ```dart
/// final response = ApiResponse<UserModel>.fromJson(json,
///     (data) => UserModel.fromJson(data));
/// if (response.success) {
///   final user = response.data!;
/// } else {
///   print(response.message);
/// }
/// ```
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final PaginationMeta? pagination;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
      errors: json['errors'] as Map<String, dynamic>?,
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convenience for list responses.
  factory ApiResponse.fromListJson(
    Map<String, dynamic> json,
    T Function(List<dynamic>) fromList,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? fromList(json['data'] as List<dynamic>) : null,
      errors: json['errors'] as Map<String, dynamic>?,
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get hasError => !success || errors != null;
}
