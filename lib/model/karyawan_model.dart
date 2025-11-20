// Model Karyawan sesuai database schema
class KaryawanModel {
  final String? id;
  final String email;
  final String? passwordHash;
  final String? fullName;
  final String? profilePicture;
  final String? phone;
  final String? jabatan;
  final String? department;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KaryawanModel({
    this.id,
    required this.email,
    this.passwordHash,
    this.fullName,
    this.profilePicture,
    this.phone,
    this.jabatan,
    this.department,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "password_hash": passwordHash,
      "full_name": fullName,
      "profile_picture": profilePicture,
      "phone": phone,
      "jabatan": jabatan,
      "department": department,
      "is_active": isActive ?? true,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  factory KaryawanModel.fromMap(Map<String, dynamic> map) {
    return KaryawanModel(
      id: map["id"]?.toString(),
      email: map["email"] ?? "",
      passwordHash: map["password_hash"],
      fullName: map["full_name"],
      profilePicture: map["profile_picture"],
      phone: map["phone"],
      jabatan: map["jabatan"],
      department: map["department"],
      isActive: map["is_active"] ?? true,
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
      updatedAt: map["updated_at"] != null
          ? DateTime.parse(map["updated_at"])
          : null,
    );
  }
}

// Model UserAssets (Assignment karyawan ke assets)
class UserAssetsModel {
  final String? id;
  final String? karyawanId;
  final String? assetsId;
  final DateTime? assignedAt;
  final DateTime? createdAt;

  UserAssetsModel({
    this.id,
    this.karyawanId,
    this.assetsId,
    this.assignedAt,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "karyawan_id": karyawanId,
      "assets_id": assetsId,
      "assigned_at": assignedAt?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
    };
  }

  factory UserAssetsModel.fromMap(Map<String, dynamic> map) {
    return UserAssetsModel(
      id: map["id"]?.toString(),
      karyawanId: map["karyawan_id"]?.toString(),
      assetsId: map["assets_id"]?.toString(),
      assignedAt: map["assigned_at"] != null
          ? DateTime.parse(map["assigned_at"])
          : null,
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
    );
  }
}
