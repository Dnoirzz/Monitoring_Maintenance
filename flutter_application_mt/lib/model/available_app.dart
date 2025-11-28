/// Model untuk aplikasi yang tersedia untuk user
class AvailableApp {
  final String karyawanAplikasiId;
  final String aplikasiId;
  final String namaAplikasi;
  final String kodeAplikasi;
  final String role;

  AvailableApp({
    required this.karyawanAplikasiId,
    required this.aplikasiId,
    required this.namaAplikasi,
    required this.kodeAplikasi,
    required this.role,
  });

  factory AvailableApp.fromJson(Map<String, dynamic> json) {
    return AvailableApp(
      karyawanAplikasiId: json['karyawan_aplikasi_id'] as String,
      aplikasiId: json['aplikasi_id'] as String,
      namaAplikasi: json['nama_aplikasi'] as String,
      kodeAplikasi: json['kode_aplikasi'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'karyawan_aplikasi_id': karyawanAplikasiId,
      'aplikasi_id': aplikasiId,
      'nama_aplikasi': namaAplikasi,
      'kode_aplikasi': kodeAplikasi,
      'role': role,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvailableApp &&
        other.karyawanAplikasiId == karyawanAplikasiId &&
        other.aplikasiId == aplikasiId &&
        other.namaAplikasi == namaAplikasi &&
        other.kodeAplikasi == kodeAplikasi &&
        other.role == role;
  }

  @override
  int get hashCode {
    return Object.hash(
      karyawanAplikasiId,
      aplikasiId,
      namaAplikasi,
      kodeAplikasi,
      role,
    );
  }
}
