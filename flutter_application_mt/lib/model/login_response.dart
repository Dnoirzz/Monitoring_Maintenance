import 'available_app.dart';

/// Model untuk response dari API Login (Step 1)
class LoginResponse {
  final bool success;
  final String karyawanId;
  final String email;
  final String fullName;
  final List<AvailableApp> availableApps;

  LoginResponse({
    required this.success,
    required this.karyawanId,
    required this.email,
    required this.fullName,
    required this.availableApps,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? true,
      karyawanId: json['karyawan_id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      availableApps:
          (json['available_apps'] as List<dynamic>)
              .map((app) => AvailableApp.fromJson(app as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'karyawan_id': karyawanId,
      'email': email,
      'full_name': fullName,
      'available_apps': availableApps.map((app) => app.toJson()).toList(),
    };
  }

  /// Filter available apps untuk MT saja
  List<AvailableApp> get mtApps {
    return availableApps.where((app) => app.kodeAplikasi == 'MT').toList();
  }

  /// Cek apakah user punya akses ke MT
  bool get hasMtAccess => mtApps.isNotEmpty;
}
