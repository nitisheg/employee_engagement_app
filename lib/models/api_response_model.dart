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
          ? PaginationMeta.fromJson(
              json['pagination'] as Map<String, dynamic>)
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
      data: json['data'] != null ? fromList(json['data'] as List) : null,
      errors: json['errors'] as Map<String, dynamic>?,
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get hasError => !success || errors != null;
}

class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      perPage: json['per_page'] as int,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
}

/// Typed API exception thrown when a request fails.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => statusCode >= 500;
}
