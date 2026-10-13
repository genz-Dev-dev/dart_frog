import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// Centralized API response builder.
///
/// Single item:
/// dart
/// ApiResponse.single(data: product.toMap(), message: 'Product found.');
/// 
///
/// Multiple items:
/// dart
/// ApiResponse.multiple(data: products.map((p) => p.toMap()).toList());
/// 
///
/// Error:
/// dart
/// ApiResponse.error('Product not found.', statusCode: HttpStatus.notFound);
/// 
class ApiResponse {
  ApiResponse._(); // non-instantiable

  // ---------------------------------------------------------------------------
  // ✅ SUCCESS — single object
  // ---------------------------------------------------------------------------
  /// Returns a 200 (or custom [statusCode]) response wrapping one item.
  ///
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Product found.",
  ///   "data": { ... }
  /// }
  /// ```
  static Response single({
    required Map<String, dynamic> data,
    String? message,
    int statusCode = HttpStatus.ok,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        if (message != null) 'message': message,
        'data': data,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ SUCCESS — list of objects
  // ---------------------------------------------------------------------------
  /// Returns a 200 response wrapping a list of items.
  ///
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "2 products found.",
  ///   "count": 2,
  ///   "data": [ ... ]
  /// }
  /// ```
  static Response multiple({
    required List<Map<String, dynamic>> data,
    String? message,
    int statusCode = HttpStatus.ok,
    Map<String, dynamic>? pagination,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message ?? '${data.length} record(s) found.',
        'count': data.length,
        if (pagination != null) 'pagination': pagination,
        'data': data,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ SUCCESS — no body (e.g. delete)
  // ---------------------------------------------------------------------------
  /// Returns a response with only a message and no data body.
  ///
  /// ```json
  /// { "success": true, "message": "Deleted successfully." }
  /// ```
  static Response message(
    String message, {
    int statusCode = HttpStatus.ok,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {'success': true, 'message': message},
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ SUCCESS — created (201)
  // ---------------------------------------------------------------------------
  /// Shortcut for a 201 Created response with one item.
  static Response created({
    required Map<String, dynamic> data,
    String message = 'Created successfully.',
  }) {
    return single(
      data: data,
      message: message,
      statusCode: HttpStatus.created,
    );
  }

  // ---------------------------------------------------------------------------
  // ❌ ERROR responses
  // ---------------------------------------------------------------------------

  /// Generic error response.
  ///
  /// ```json
  /// { "success": false, "error": "Something went wrong." }
  /// ```
  static Response error(
    String error, {
    int statusCode = HttpStatus.badRequest,
    Map<String, dynamic>? details,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'error': error,
        if (details != null) 'details': details,
      },
    );
  }

  /// 400 Bad Request
  static Response badRequest(String error, {Map<String, dynamic>? details}) =>
      ApiResponse.error(error,
          statusCode: HttpStatus.badRequest, details: details);

  /// 401 Unauthorized
  static Response unauthorized([String error = 'Unauthorized.']) =>
      ApiResponse.error(error, statusCode: HttpStatus.unauthorized);

  /// 403 Forbidden
  static Response forbidden([String error = 'Forbidden.']) =>
      ApiResponse.error(error, statusCode: HttpStatus.forbidden);

  /// 404 Not Found
  static Response notFound([String error = 'Resource not found.']) =>
      ApiResponse.error(error, statusCode: HttpStatus.notFound);

  /// 409 Conflict (e.g. duplicate email)
  static Response conflict([String error = 'Resource already exists.']) =>
      ApiResponse.error(error, statusCode: HttpStatus.conflict);

  /// 422 Unprocessable Entity (validation failed)
  static Response validation(
    String error, {
    Map<String, dynamic>? details,
  }) =>
      ApiResponse.error(error,
          statusCode: HttpStatus.unprocessableEntity, details: details);

  /// 500 Internal Server Error
  static Response serverError([String error = 'Internal server error.']) =>
      ApiResponse.error(error, statusCode: HttpStatus.internalServerError);

  // ---------------------------------------------------------------------------
  // 🔧 Utilities
  // ---------------------------------------------------------------------------

  /// Strips the "Exception: " prefix Dart adds to exception messages.
  static String cleanError(Object e) =>
      e.toString().replaceAll('Exception: ', '').trim();

  /// Builds a pagination map to attach to [multiple].
  /// ```dart
  /// ApiResponse.multiple(
  ///   data: items,
  ///   pagination: ApiResponse.paginate(page: 1, limit: 10, total: 45),
  /// );
  /// ```
  static Map<String, dynamic> paginate({
    required int page,
    required int limit,
    required int total,
  }) {
    final totalPages = (total / limit).ceil();
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
      'has_next': page < totalPages,
      'has_prev': page > 1,
    };
  }
}

