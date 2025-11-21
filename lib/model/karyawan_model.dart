class KaryawanModel {
  final String nama;
  final String mesin;
  final String telp;
  final String email;
  final String password;

  KaryawanModel({
    required this.nama,
    required this.mesin,
    required this.telp,
    required this.email,
    required this.password,
  });

  Map<String, String> toMap() {
    return {
      "nama": nama,
      "mesin": mesin,
      "telp": telp,
      "email": email,
      "password": password,
    };
  }

  factory KaryawanModel.fromMap(Map<String, String> map) {
    return KaryawanModel(
      nama: map["nama"] ?? "",
      mesin: map["mesin"] ?? "",
      telp: map["telp"] ?? "",
      email: map["email"] ?? "",
      password: map["password"] ?? "",
    );
  }
}

