import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/auth_response_model.dart';

/// Service untuk menangani autentikasi
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Login dengan email dan password
  ///
  /// Throws [AuthException] jika terjadi error
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = ApiConfig.loginEndpoint;

      // Debug: Log URL yang digunakan (jangan log di production)
      // print('🔗 Login URL: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw AuthException(
                'Request timeout. Pastikan URL backend benar dan server sedang berjalan.',
              );
            },
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw AuthException('Email atau password salah');
      } else if (response.statusCode == 404) {
        throw AuthException(
          'Endpoint tidak ditemukan. Pastikan URL backend benar: $url',
        );
      } else {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage =
            errorBody?['message'] as String? ??
            'Terjadi kesalahan saat login. Silakan coba lagi.';
        throw AuthException(errorMessage);
      }
    } on http.ClientException {
      // Cek apakah ini masalah URL atau koneksi
      final url = ApiConfig.loginEndpoint;
      if (url.contains('yourdomain.com') || url.contains('example.com')) {
        throw AuthException(
          '⚠️ URL backend belum dikonfigurasi!\n\n'
          'Silakan update baseUrl di file:\n'
          'lib/config/api_config.dart\n\n'
          'URL saat ini: $url',
        );
      }
      throw AuthException(
        'Tidak ada koneksi internet atau server tidak dapat dijangkau.\n\n'
        'URL yang dicoba: $url\n\n'
        'Pastikan:\n'
        '1. Koneksi internet aktif\n'
        '2. URL backend benar\n'
        '3. Server backend sedang berjalan',
      );
    } on FormatException {
      throw AuthException('Format response tidak valid dari server');
    } on AuthException {
      rethrow;
    } catch (e) {
      // Cek apakah error terkait URL
      final url = ApiConfig.loginEndpoint;
      if (url.contains('yourdomain.com') || url.contains('example.com')) {
        throw AuthException(
          '⚠️ URL backend belum dikonfigurasi!\n\n'
          'Silakan update baseUrl di file:\n'
          'lib/config/api_config.dart',
        );
      }
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }
}

/// Exception untuk error autentikasi
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
