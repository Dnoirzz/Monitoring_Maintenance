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

  MtTemplate({
    this.id,
    this.bgMesinId,
    this.periode,
    this.intervalPeriode,
    this.startDate,
    this.createdAt,
    this.updatedAt,
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
  }) {
    return MtTemplate(
      id: id ?? this.id,
      bgMesinId: bgMesinId ?? this.bgMesinId,
      periode: periode ?? this.periode,
      intervalPeriode: intervalPeriode ?? this.intervalPeriode,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name for template (using bg_mesin name if available)
  String get displayName {
    return periode != null ? 'Periode: $periode' : 'Template';
  }
}
