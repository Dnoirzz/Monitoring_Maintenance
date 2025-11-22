import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// State untuk autentikasi
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userId;
  final String? userEmail;
  final String? userFullName;
  final String? userRole;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.userEmail,
    this.userFullName,
    this.userRole,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userId,
    String? userEmail,
    String? userFullName,
    String? userRole,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userFullName: userFullName ?? this.userFullName,
      userRole: userRole ?? this.userRole,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider untuk AuthState
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Notifier untuk mengelola state autentikasi
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Cek status autentikasi saat app pertama kali dibuka
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      final userId = await _storageService.getUserId();
      final userEmail = await _storageService.getUserEmail();
      final userFullName = await _storageService.getUserFullName();
      final userRole = await _storageService.getUserRole();

      state = state.copyWith(
        isAuthenticated: true,
        userId: userId,
        userEmail: userEmail,
        userFullName: userFullName,
        userRole: userRole,
      );
    }
  }

  /// Login dengan email dan password
  ///
  /// Logic:
  /// 1. Kirim request ke API login
  /// 2. Cek apakah ada tiket MT di available_apps
  /// 3. Jika ada, simpan token dan role, lalu set authenticated
  /// 4. Jika tidak ada, throw error dengan pesan akses ditolak
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Kirim request ke API login
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // 2. Cek apakah ada tiket MT di available_apps
      final mtAccess = response.availableApps.firstWhere(
        (app) => app.kodeAplikasi == 'MT',
        orElse:
            () =>
                throw AuthException(
                  'Anda tidak memiliki akses ke System Maintenance. Hubungi IT.',
                ),
      );

      // 3. Validasi role
      final validRoles = [
        'Superadmin',
        'Manajer',
        'Admin',
        'KASIE Teknisi',
        'Teknisi',
      ];

      if (!validRoles.contains(mtAccess.role)) {
        throw AuthException(
          'Role "${mtAccess.role}" tidak valid untuk System Maintenance. Hubungi IT.',
        );
      }

      // 4. Simpan token dan data user ke storage
      await _storageService.saveToken(response.token);
      await _storageService.saveUserData(
        userId: response.user.id,
        email: response.user.email,
        fullName: response.user.fullName,
        role: mtAccess.role,
      );

      // 5. Update state
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: response.user.id,
        userEmail: response.user.email,
        userFullName: response.user.fullName,
        userRole: mtAccess.role,
        clearError: true,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storageService.clearAll();
    state = AuthState();
  }

  /// Get current token
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }
}
