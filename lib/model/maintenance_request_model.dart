/// Maintenance Request Model
/// Represents the structure of the 'maintenance_request' table in Supabase
class MaintenanceRequest {
  final String? id; // uuid
  final String? requesterId; // uuid
  final String? assetsId; // uuid
  final String? judul;
  final String? requestType; // enum
  final String? priority; // enum: 'Low', 'Medium', 'High', 'Critical'
  final String? keterangan;
  final String
  status; // enum: 'Pending', 'In Progress', 'Completed', 'Rejected'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data
  final Map<String, dynamic>? asset;

  MaintenanceRequest({
    this.id,
    this.requesterId,
    this.assetsId,
    this.judul,
    this.requestType,
    this.priority = 'Medium',
    this.keterangan,
    this.status = 'Pending',
    this.createdAt,
    this.updatedAt,
    this.asset,
  });

  /// Create MaintenanceRequest from JSON
  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] as String?,
      requesterId: json['requester_id'] as String?,
      assetsId: json['assets_id'] as String?,
      judul: json['judul'] as String?,
      requestType: json['request_type'] as String?,
      priority: json['priority'] as String? ?? 'Medium',
      keterangan: json['keterangan'] as String?,
      status: json['status'] as String? ?? 'Pending',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      asset: json['assets'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (requesterId != null) 'requester_id': requesterId,
      if (assetsId != null) 'assets_id': assetsId,
      if (judul != null) 'judul': judul,
      if (requestType != null) 'request_type': requestType,
      'priority': priority,
      if (keterangan != null) 'keterangan': keterangan,
      'status': status,
    };
  }

  /// Get asset name from joined data
  String? get assetName {
    return asset?['nama_assets'] as String?;
  }

  String? get assetLocation {
    // Assuming location might be derived or stored in asset,
    // but schema doesn't strictly have 'lokasi'.
    // We'll try to get it if it exists, or return null.
    // Based on schema, assets table has 'nama_assets', 'kode_assets', 'jenis_assets', 'foto'.
    // Location might be inferred or we might need to join with bg_mesin?
    // For now, let's just return null or empty if not found.
    return null;
  }
}
