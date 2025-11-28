import 'check_sheet_model.dart';

/// Model untuk Check Sheet Template di Supabase
/// Sesuai dengan struktur tabel cek_sheet_template yang sebenarnya
class CheckSheetTemplateModel {
  final String? id; // UUID
  final String? komponenAssetsId; // UUID, foreign key ke komponen_assets
  final String? periode; // enum periode_enum (Harian, Mingguan, Bulanan)
  final String? jenisPekerjaan;
  final String? stdPrwtn; // standar perawatan
  final String? alatBahan;
  final int? intervalPeriode; // interval dalam periode
  final DateTime? createdAt;

  CheckSheetTemplateModel({
    this.id,
    this.komponenAssetsId,
    this.periode,
    this.jenisPekerjaan,
    this.stdPrwtn,
    this.alatBahan,
    this.intervalPeriode,
    this.createdAt,
  });

  /// Convert dari JSON (dari Supabase)
  factory CheckSheetTemplateModel.fromJson(Map<String, dynamic> json) {
    return CheckSheetTemplateModel(
      id: json['id'] as String?,
      komponenAssetsId: json['komponen_assets_id'] as String?,
      periode: json['periode'] as String?,
      jenisPekerjaan: json['jenis_pekerjaan'] as String?,
      stdPrwtn: json['std_prwtn'] as String?,
      alatBahan: json['alat_bahan'] as String?,
      intervalPeriode: json['interval_periode'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert ke JSON (untuk Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (komponenAssetsId != null) 'komponen_assets_id': komponenAssetsId,
      if (periode != null) 'periode': periode,
      if (jenisPekerjaan != null) 'jenis_pekerjaan': jenisPekerjaan,
      if (stdPrwtn != null) 'std_prwtn': stdPrwtn,
      if (alatBahan != null) 'alat_bahan': alatBahan,
      if (intervalPeriode != null) 'interval_periode': intervalPeriode,
    };
  }

  /// Copy with untuk update
  CheckSheetTemplateModel copyWith({
    String? id,
    String? komponenAssetsId,
    String? periode,
    String? jenisPekerjaan,
    String? stdPrwtn,
    String? alatBahan,
    int? intervalPeriode,
    DateTime? createdAt,
  }) {
    return CheckSheetTemplateModel(
      id: id ?? this.id,
      komponenAssetsId: komponenAssetsId ?? this.komponenAssetsId,
      periode: periode ?? this.periode,
      jenisPekerjaan: jenisPekerjaan ?? this.jenisPekerjaan,
      stdPrwtn: stdPrwtn ?? this.stdPrwtn,
      alatBahan: alatBahan ?? this.alatBahan,
      intervalPeriode: intervalPeriode ?? this.intervalPeriode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model untuk data lengkap dengan join ke komponen_assets
class CheckSheetTemplateWithKomponen {
  final CheckSheetTemplateModel template;
  final Map<String, dynamic>? komponenAsset;
  final Map<String, dynamic>? bagianMesin;
  final Map<String, dynamic>? asset;

  CheckSheetTemplateWithKomponen({
    required this.template,
    this.komponenAsset,
    this.bagianMesin,
    this.asset,
  });

  /// Helper untuk mendapatkan nama infrastruktur
  /// Nama infrastruktur = nama aset dari tabel assets
  String? get namaInfrastruktur {
    if (asset == null) return null;
    // Coba berbagai kemungkinan nama field
    return asset?['nama_assets'] as String? ?? 
           asset?['nama_aset'] as String? ?? 
           asset?['nama'] as String?;
  }

  /// Helper untuk mendapatkan nama bagian
  String? get namaBagian => bagianMesin?['nama_bagian'] as String?;

  /// Helper untuk mendapatkan nama komponen
  /// Di tabel komponen_assets, field untuk nama komponen adalah 'nama_bagian'
  String? get namaKomponen => komponenAsset?['nama_bagian'] as String?;

  /// Convert ke CheckSheetModel untuk kompatibilitas dengan UI
  CheckSheetModel toCheckSheetModel({required int no}) {
    // Format periode dengan interval
    // Enum di database: 'Hari', 'Minggu', 'Bulan'
    String periodeText = '';
    if (template.periode != null && template.intervalPeriode != null) {
      String unit = '';
      switch (template.periode) {
        case 'Hari':
          unit = 'Hari';
          break;
        case 'Minggu':
          unit = 'Minggu';
          break;
        case 'Bulan':
          unit = 'Bulan';
          break;
        default:
          // Fallback untuk format lain (case-insensitive)
          final periodeLower = template.periode!.toLowerCase();
          if (periodeLower.contains('hari')) {
            unit = 'Hari';
          } else if (periodeLower.contains('minggu')) {
            unit = 'Minggu';
          } else if (periodeLower.contains('bulan')) {
            unit = 'Bulan';
          } else {
            unit = template.periode ?? 'Hari';
          }
      }
      periodeText = 'Per ${template.intervalPeriode} $unit';
    } else if (template.periode != null) {
      periodeText = template.periode!;
    }

    return CheckSheetModel(
      no: no,
      namaInfrastruktur: namaInfrastruktur ?? 'Unknown',
      bagian: namaKomponen ?? namaBagian ?? 'Unknown',
      periode: periodeText,
      jenisPekerjaan: template.jenisPekerjaan ?? '',
      standarPerawatan: template.stdPrwtn ?? '',
      alatBahan: template.alatBahan ?? '',
    );
  }
}
