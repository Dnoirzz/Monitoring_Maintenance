import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_client.dart';
import '../model/available_app.dart';
import '../model/app_user.dart';

/// Auth step indicator
enum AuthStep {
  initial,
  loggedIn, // Step 1 complete - has available apps
  authenticated, // Step 2 complete - has token
}

/// State untuk autentikasi 2-step
class AuthState {
  final bool isLoading;
  final AuthStep step;
  final String? karyawanId;
  final String? userEmail;
  final String? userFullName;
  final List<AvailableApp> availableApps;
  final AppUser? currentUser;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.step = AuthStep.initial,
    this.karyawanId,
    this.userEmail,
    this.userFullName,
    this.availableApps = const [],
    this.currentUser,
    this.errorMessage,
  });

  bool get isAuthenticated => step == AuthStep.authenticated;
  bool get hasAvailableApps => availableApps.isNotEmpty;

  /// Get MT apps only
  List<AvailableApp> get mtApps {
    return availableApps.where((app) => app.kodeAplikasi == 'MT').toList();
  }

  AuthState copyWith({
    bool? isLoading,
    AuthStep? step,
    String? karyawanId,
    String? userEmail,
    String? userFullName,
    List<AvailableApp>? availableApps,
    AppUser? currentUser,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      step: step ?? this.step,
      karyawanId: karyawanId ?? this.karyawanId,
      userEmail: userEmail ?? this.userEmail,
      userFullName: userFullName ?? this.userFullName,
      availableApps: availableApps ?? this.availableApps,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider untuk AuthState
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Notifier untuk mengelola state autentikasi 2-step
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ApiClient _apiClient = ApiClient();

  AuthNotifier() : super(AuthState()) {
    _init();
  }

  /// Initialize - check existing session dan setup 401 handler
  Future<void> _init() async {
    // Setup 401 handler untuk auto-logout
    _apiClient.setOnUnauthorized(() {
      logout();
    });

    await _checkAuthStatus();
  }

  /// Cek status autentikasi saat app pertama kali dibuka
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      final userId = await _storageService.getUserId();
      final userEmail = await _storageService.getUserEmail();
      final userFullName = await _storageService.getUserFullName();
      final userRole = await _storageService.getUserRole();

      if (userId != null && userEmail != null && userRole != null) {
        state = state.copyWith(
          step: AuthStep.authenticated,
          karyawanId: userId,
          userEmail: userEmail,
          userFullName: userFullName,
        );
      }
    }
  }

  /// Step 1: Login dengan email dan password
  /// Returns true jika perlu select app, false jika auto-select
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Call login API
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // 2. Filter MT apps only
      final mtApps = response.mtApps;

      if (mtApps.isEmpty) {
        throw AuthException(
          'Anda tidak memiliki akses ke aplikasi Maintenance Tracking. Hubungi IT.',
        );
      }

      // 3. Update state dengan available apps
      state = state.copyWith(
        isLoading: false,
        step: AuthStep.loggedIn,
        karyawanId: response.karyawanId,
        userEmail: response.email,
        userFullName: response.fullName,
        availableApps: mtApps,
        clearError: true,
      );

      // 4. Auto-select jika hanya 1 MT app
      if (mtApps.length == 1) {
        await selectApp(mtApps.first.aplikasiId);
        return false; // No need to show app selection
      }

      return true; // Need to show app selection
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        step: AuthStep.initial,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        step: AuthStep.initial,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Step 2: Select app dan dapatkan token
  Future<void> selectApp(String aplikasiId) async {
    if (state.karyawanId == null) {
      throw AuthException('Silakan login terlebih dahulu');
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Call select-app API
      final response = await _authService.selectApp(
        karyawanId: state.karyawanId!,
        aplikasiId: aplikasiId,
      );

      // 2. Save token dan user data ke storage
      await _storageService.saveToken(response.token);
      await _storageService.saveUserData(
        userId: response.user.karyawanId,
        email: response.user.email,
        fullName: response.user.fullName,
        role: response.user.role,
      );

      // 3. Update state
      state = state.copyWith(
        isLoading: false,
        step: AuthStep.authenticated,
        currentUser: response.user,
        clearError: true,
      );
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Logout - clear semua data
  Future<void> logout() async {
    await _storageService.clearAll();
    state = AuthState();
  }

  /// Get current token
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  /// Get user role
  String? get userRole => state.currentUser?.role;
}
