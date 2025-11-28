/// MT Template Model
/// Represents the structure of the 'mt_template' table in Supabase
class MtTemplate {
  final String? id; // uuid
  final String? bgMesinId; // uuid
  final String? periode; // enum
  final int? intervalPeriode;
  final DateTime? startDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Joined data (optional, loaded separately)
  final Map<String, dynamic>? bgMesin; // bg_mesin table data

  MtTemplate({
    this.id,
    this.bgMesinId,
    this.periode,
    this.intervalPeriode,
    this.startDate,
    this.createdAt,
    this.updatedAt,
    this.bgMesin,
  });

  /// Create MtTemplate from JSON (from Supabase)
  factory MtTemplate.fromJson(Map<String, dynamic> json) {
    return MtTemplate(
      id: json['id'] as String?,
      bgMesinId: json['bg_mesin_id'] as String?,
      periode: json['periode'] as String?,
      intervalPeriode: json['interval_periode'] as int?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      bgMesin: json['bg_mesin'] as Map<String, dynamic>?,
    );
  }

  /// Convert MtTemplate to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (bgMesinId != null) 'bg_mesin_id': bgMesinId,
      if (periode != null) 'periode': periode,
      if (intervalPeriode != null) 'interval_periode': intervalPeriode,
      if (startDate != null) 'start_date': startDate!.toIso8601String().split('T')[0],
    };
  }

  MtTemplate copyWith({
    String? id,
    String? bgMesinId,
    String? periode,
    int? intervalPeriode,
    DateTime? startDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? bgMesin,
  }) {
    return MtTemplate(
      id: id ?? this.id,
      bgMesinId: bgMesinId ?? this.bgMesinId,
      periode: periode ?? this.periode,
      intervalPeriode: intervalPeriode ?? this.intervalPeriode,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bgMesin: bgMesin ?? this.bgMesin,
    );
  }

  /// Get display name for template (using bg_mesin name if available)
  String get displayName {
    return periode != null ? 'Periode: $periode' : 'Template';
  }

  /// Get bagian mesin name from joined data
  String? get bagianMesinName {
    return bgMesin?['nama_bagian'] as String?;
  }
}
