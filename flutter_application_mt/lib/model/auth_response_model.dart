/// Model untuk response dari API Login
class AuthResponseModel {
  final UserModel user;
  final String token;
  final List<AppAccessModel> availableApps;

  AuthResponseModel({
    required this.user,
    required this.token,
    required this.availableApps,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      availableApps:
          (json['available_apps'] as List<dynamic>)
              .map(
                (app) => AppAccessModel.fromJson(app as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'available_apps': availableApps.map((app) => app.toJson()).toList(),
    };
  }
}

/// Model untuk data user
class UserModel {
  final String id;
  final String email;
  final String fullName;

  UserModel({required this.id, required this.email, required this.fullName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'full_name': fullName};
  }
}

/// Model untuk akses aplikasi (Tiket)
class AppAccessModel {
  final String kodeAplikasi;
  final String role;

  AppAccessModel({required this.kodeAplikasi, required this.role});

  factory AppAccessModel.fromJson(Map<String, dynamic> json) {
    return AppAccessModel(
      kodeAplikasi: json['kode_aplikasi'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'kode_aplikasi': kodeAplikasi, 'role': role};
  }
}
