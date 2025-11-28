class CheckSheetModel {
  final int no;
  final String namaInfrastruktur;
  final String bagian;
  final String periode;
  final String jenisPekerjaan;
  final String standarPerawatan;
  final String alatBahan;
  final String kategori;
  final Map<int, String> tanggalStatus;

  CheckSheetModel({
    required this.no,
    required this.namaInfrastruktur,
    required this.bagian,
    required this.periode,
    required this.jenisPekerjaan,
    required this.standarPerawatan,
    required this.alatBahan,
    Map<int, String>? tanggalStatus,
    this.kategori = 'Mesin Produksi',
  }) : tanggalStatus = Map<int, String>.from(tanggalStatus ?? {});

  CheckSheetModel copyWith({
    int? no,
    String? namaInfrastruktur,
    String? bagian,
    String? periode,
    String? jenisPekerjaan,
    String? standarPerawatan,
    String? alatBahan,
    String? kategori,
    Map<int, String>? tanggalStatus,
  }) {
    return CheckSheetModel(
      no: no ?? this.no,
      namaInfrastruktur: namaInfrastruktur ?? this.namaInfrastruktur,
      bagian: bagian ?? this.bagian,
      periode: periode ?? this.periode,
      jenisPekerjaan: jenisPekerjaan ?? this.jenisPekerjaan,
      standarPerawatan: standarPerawatan ?? this.standarPerawatan,
      alatBahan: alatBahan ?? this.alatBahan,
      kategori: kategori ?? this.kategori,
      tanggalStatus: tanggalStatus ?? this.tanggalStatus,
    );
  }
}

