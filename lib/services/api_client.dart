import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

/// Callback untuk handle unauthorized (401) response
typedef OnUnauthorizedCallback = void Function();

/// HTTP Client dengan auto-attach token dan 401 handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final StorageService _storageService = StorageService();
  OnUnauthorizedCallback? _onUnauthorized;

  /// Set callback untuk handle 401 response
  void setOnUnauthorized(OnUnauthorizedCallback callback) {
    _onUnauthorized = callback;
  }

  /// Get base headers dengan optional token
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (withAuth) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle response dan check for 401
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // Token expired atau invalid
      _onUnauthorized?.call();
      throw ApiException(
        statusCode: 401,
        message: 'Sesi telah berakhir. Silakan login kembali.',
      );
    }

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Handle error response
    final message = body['message'] as String? ?? 'Terjadi kesalahan';
    throw ApiException(statusCode: response.statusCode, message: message);
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    bool withAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      final headers = await _getHeaders(withAuth: withAuth);

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout);

      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak dapat terhubung ke server',
      );
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      final headers = await _getHeaders(withAuth: withAuth);

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak dapat terhubung ke server',
      );
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      final headers = await _getHeaders(withAuth: withAuth);

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak dapat terhubung ke server',
      );
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool withAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      final headers = await _getHeaders(withAuth: withAuth);

      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(timeout);

      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak dapat terhubung ke server',
      );
    }
  }
}

/// Exception untuk API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}
