/// Info aplikasi yang sedang diakses
class AppInfo {
  final String nama;
  final String kode;

  AppInfo({required this.nama, required this.kode});

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(nama: json['nama'] as String, kode: json['kode'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'nama': nama, 'kode': kode};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppInfo && other.nama == nama && other.kode == kode;
  }

  @override
  int get hashCode => Object.hash(nama, kode);
}

/// Model untuk data user setelah select app
class AppUser {
  final String karyawanId;
  final String email;
  final String fullName;
  final String role;
  final String? profilePicture;
  final AppInfo aplikasi;

  AppUser({
    required this.karyawanId,
    required this.email,
    required this.fullName,
    required this.role,
    this.profilePicture,
    required this.aplikasi,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      karyawanId: json['karyawan_id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      profilePicture: json['profile_picture'] as String?,
      aplikasi: AppInfo.fromJson(json['aplikasi'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'karyawan_id': karyawanId,
      'email': email,
      'full_name': fullName,
      'role': role,
      'profile_picture': profilePicture,
      'aplikasi': aplikasi.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.karyawanId == karyawanId &&
        other.email == email &&
        other.fullName == fullName &&
        other.role == role &&
        other.profilePicture == profilePicture &&
        other.aplikasi == aplikasi;
  }

  @override
  int get hashCode {
    return Object.hash(
      karyawanId,
      email,
      fullName,
      role,
      profilePicture,
      aplikasi,
    );
  }
}
