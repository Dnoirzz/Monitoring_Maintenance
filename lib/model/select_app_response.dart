import 'app_user.dart';

/// Model untuk response dari API Select App (Step 2)
class SelectAppResponse {
  final bool success;
  final String token;
  final AppUser user;

  SelectAppResponse({
    required this.success,
    required this.token,
    required this.user,
  });

  factory SelectAppResponse.fromJson(Map<String, dynamic> json) {
    return SelectAppResponse(
      success: json['success'] as bool? ?? true,
      token: json['token'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'token': token, 'user': user.toJson()};
  }
}
