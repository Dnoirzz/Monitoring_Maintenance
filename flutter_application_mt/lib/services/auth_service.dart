import 'api_client.dart';
import '../model/login_response.dart';
import '../model/select_app_response.dart';
import '../model/app_user.dart';

/// Service untuk menangani autentikasi 2-step
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Step 1: Login dengan email dan password
  /// Returns LoginResponse dengan available_apps
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/login',
        body: {'email': email, 'password': password},
        withAuth: false,
      );

      return LoginResponse.fromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Step 2: Select app dan dapatkan JWT token
  /// Returns SelectAppResponse dengan token dan user info
  Future<SelectAppResponse> selectApp({
    required String karyawanId,
    required String aplikasiId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/select-app',
        body: {'karyawan_id': karyawanId, 'aplikasi_id': aplikasiId},
        withAuth: false,
      );

      return SelectAppResponse.fromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get current user profile dari token
  Future<AppUser> getProfile() async {
    try {
      final response = await _apiClient.get('/api/auth/me', withAuth: true);

      final data = response as Map<String, dynamic>;
      return AppUser.fromJson(data['user'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
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
