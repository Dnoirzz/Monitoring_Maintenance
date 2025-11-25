import '../model/check_sheet_model.dart';
import '../model/check_sheet_template_model.dart';
import '../repositories/check_sheet_template_repository.dart';

class CheckSheetController {
  final List<CheckSheetModel> _schedules = [];
  final CheckSheetTemplateRepository _repository = CheckSheetTemplateRepository();
  
  // Mapping untuk menyimpan ID template dari Supabase (UUID)
  // Key: CheckSheetModel.no, Value: template ID (UUID) dari Supabase
  final Map<int, String> _noToTemplateIdMap = {};

  /// Load data dari Supabase dengan join ke komponen_assets
  Future<void> loadFromSupabase() async {
    try {
      _schedules.clear();
      _noToTemplateIdMap.clear();
      
      print('📥 Memuat data cek sheet dari Supabase...');
      final templatesWithJoin = await _repository.getAllTemplatesWithJoin();
      print('✅ Ditemukan ${templatesWithJoin.length} template');
      
      int no = 1;
      
      for (var templateWithJoin in templatesWithJoin) {
        // Debug: print nama infrastruktur
        final namaInfra = templateWithJoin.namaInfrastruktur;
        print('📋 Template $no: namaInfrastruktur = $namaInfra');
        
        // Convert ke CheckSheetModel untuk kompatibilitas dengan UI
        final checkSheetModel = templateWithJoin.toCheckSheetModel(no: no);
        print('  - CheckSheetModel: ${checkSheetModel.namaInfrastruktur} - ${checkSheetModel.bagian}');
        
        _schedules.add(checkSheetModel);
        
        // Simpan mapping no ke template ID (UUID)
        if (templateWithJoin.template.id != null) {
          _noToTemplateIdMap[no] = templateWithJoin.template.id!;
        }
        no++;
      }
      
      print('✅ Berhasil memuat ${_schedules.length} schedule');
    } catch (e, stackTrace) {
      print('❌ Error loading from Supabase: $e');
      print('Stack trace: $stackTrace');
      // Jika error, gunakan sample data sebagai fallback
      initializeSampleData();
    }
  }

  void initializeSampleData() {
    _schedules.clear();
    _noToTemplateIdMap.clear();
    _schedules.addAll([
      CheckSheetModel(
        no: 1,
        namaInfrastruktur: "SCREW BREAKER",
        bagian: "Pisau Duduk",
        periode: "Per 1 Minggu",
        jenisPekerjaan: "Cek hasil potongan remahan",
        standarPerawatan: "Ukuran output remahan < 15cm",
        alatBahan: "Kunci 33,48,28,19,41,24",
      ),
      CheckSheetModel(
        no: 2,
        namaInfrastruktur: "SCREW BREAKER",
        bagian: "Pisau Duduk",
        periode: "Per 2 Minggu",
        jenisPekerjaan: "Las tambah daging + pengasahan",
        standarPerawatan: "Ujung pisau max 3mm dari screen",
        alatBahan: "Kunci 33,48,28,19,41,24",
      ),
      CheckSheetModel(
        no: 3,
        namaInfrastruktur: "SCREW BREAKER",
        bagian: "V-Belt",
        periode: "Per 3 Hari",
        jenisPekerjaan: "Cek",
        standarPerawatan: "Tidak ada slip, retak, getar",
        alatBahan: "Kunci 33,48,28,19,41,24",
      ),
      CheckSheetModel(
        no: 4,
        namaInfrastruktur: "SCREW BREAKER",
        bagian: "Gearbox",
        periode: "Per 12 Bulan",
        jenisPekerjaan: "Ganti Oli",
        standarPerawatan: "Volume oli sesuai standard",
        alatBahan: "Kunci 33,48,28,19,41,24",
      ),
    ]);
  }

  List<CheckSheetModel> getAllSchedules() {
    return List.unmodifiable(_schedules);
  }

  List<CheckSheetModel> filterSchedules({String? searchQuery}) {
    List<CheckSheetModel> filtered = List.from(_schedules);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((schedule) {
        return schedule.namaInfrastruktur.toLowerCase().contains(query) ||
            schedule.bagian.toLowerCase().contains(query) ||
            schedule.periode.toLowerCase().contains(query) ||
            schedule.jenisPekerjaan.toLowerCase().contains(query) ||
            schedule.standarPerawatan.toLowerCase().contains(query) ||
            schedule.alatBahan.toLowerCase().contains(query);
      }).toList();
    }
    return filtered;
  }

  Map<String, List<CheckSheetModel>> groupByInfrastruktur(
    List<CheckSheetModel> schedules,
  ) {
    final Map<String, List<CheckSheetModel>> grouped = {};
    for (var schedule in schedules) {
      grouped.putIfAbsent(schedule.namaInfrastruktur, () => []);
      grouped[schedule.namaInfrastruktur]!.add(schedule);
    }
    return grouped;
  }

  Map<String, List<CheckSheetModel>> groupByBagian(
    List<CheckSheetModel> schedules,
  ) {
    final Map<String, List<CheckSheetModel>> grouped = {};
    for (var schedule in schedules) {
      grouped.putIfAbsent(schedule.bagian, () => []);
      grouped[schedule.bagian]!.add(schedule);
    }
    return grouped;
  }

  /// Parse periode text menjadi enum dan interval
  /// Contoh: "Per 1 Minggu" -> periode: "Minggu", interval: 1
  /// Enum di database: 'Hari', 'Minggu', 'Bulan'
  Map<String, dynamic> _parsePeriode(String periodeText) {
    final regex = RegExp(r'Per\s+(\d+)\s+(Hari|Minggu|Bulan)');
    final match = regex.firstMatch(periodeText);
    
    if (match != null) {
      final interval = int.tryParse(match.group(1) ?? '1') ?? 1;
      final unit = match.group(2) ?? 'Hari';
      
      // Enum di database: 'Hari', 'Minggu', 'Bulan'
      String periodeEnum = 'Hari';
      switch (unit) {
        case 'Hari':
          periodeEnum = 'Hari';
          break;
        case 'Minggu':
          periodeEnum = 'Minggu';
          break;
        case 'Bulan':
          periodeEnum = 'Bulan';
          break;
      }
      
      return {
        'periode': periodeEnum,
        'interval': interval,
      };
    }
    
    // Default jika tidak match
    return {
      'periode': 'Hari',
      'interval': 1,
    };
  }

  /// Convert periode dari format UI ke format enum database
  /// Enum di database: 'Hari', 'Minggu', 'Bulan'
  String _convertPeriodeToEnum(String periode) {
    final periodeLower = periode.toLowerCase();
    
    // Mapping dari berbagai format ke enum database
    if (periodeLower.contains('hari') || periodeLower == 'harian') {
      return 'Hari';
    } else if (periodeLower.contains('minggu') || periodeLower == 'mingguan') {
      return 'Minggu';
    } else if (periodeLower.contains('bulan') || periodeLower == 'bulanan') {
      return 'Bulan';
    }
    
    // Jika sudah dalam format enum yang benar, return as is
    if (periode == 'Hari' || periode == 'Minggu' || periode == 'Bulan') {
      return periode;
    }
    
    // Default
    return 'Hari';
  }

  /// Add check sheet template langsung dengan komponen_assets_id
  Future<void> addCheckSheetTemplate({
    required String komponenAssetsId,
    required String periode,
    required int intervalPeriode,
    required String jenisPekerjaan,
    required String stdPrwtn,
    required String alatBahan,
  }) async {
    try {
      print('💾 Menyimpan cek sheet template dengan komponen_id: $komponenAssetsId');
      print('📅 Periode input: $periode');
      
      // Convert periode ke format enum database: 'Hari', 'Minggu', 'Bulan'
      final periodeEnum = _convertPeriodeToEnum(periode);
      print('📅 Periode enum: $periodeEnum');
      
      // Simpan ke Supabase
      final template = await _repository.createTemplate(
        komponenAssetsId: komponenAssetsId,
        periode: periodeEnum,
        intervalPeriode: intervalPeriode,
        jenisPekerjaan: jenisPekerjaan,
        stdPrwtn: stdPrwtn,
        alatBahan: alatBahan,
      );
      
      print('✅ Template berhasil dibuat dengan ID: ${template.id}');
      
      // Jangan reload data di sini untuk menghindari freeze
      // Data akan di-reload oleh UI setelah semua komponen tersimpan
      // await loadFromSupabase();
    } catch (e, stackTrace) {
      print('❌ Error adding check sheet template: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Add schedules dari form dan simpan ke Supabase
  /// Note: Untuk struktur baru, setiap bagian perlu komponen_assets_id
  /// Untuk sementara, kita akan mencari komponen berdasarkan nama
  Future<void> addSchedulesFromForm({
    required String namaInfrastruktur,
    required List<CheckSheetSectionInput> bagianItems,
  }) async {
    try {
      print('🔍 Mencari komponen assets untuk: $namaInfrastruktur');
      
      // Ambil semua komponen assets untuk mencari yang sesuai
      final komponenAssets = await _repository.getKomponenAssets();
      print('📦 Ditemukan ${komponenAssets.length} komponen assets');
      
      if (komponenAssets.isEmpty) {
        throw Exception('Tidak ada komponen assets di database. Silakan tambahkan komponen assets terlebih dahulu.');
      }
      
      int startNo = _schedules.isEmpty ? 1 : _schedules.last.no + 1;
      
      for (var section in bagianItems) {
        print('🔎 Mencari komponen untuk: ${section.bagian}');
        
        // Cari komponen asset berdasarkan nama bagian dan nama infrastruktur
        Map<String, dynamic>? selectedKomponen;
        
        for (var komponen in komponenAssets) {
          final bgMesin = komponen['bg_mesin'] as Map<String, dynamic>?;
          final asset = bgMesin?['assets'] as Map<String, dynamic>?;
          
          // Coba berbagai kemungkinan nama field
          final namaAsset = asset?['nama_aset'] as String? ?? 
                           asset?['nama_assets'] as String? ??
                           asset?['nama'] as String?;
          final namaKomponen = komponen['nama_komponen'] as String?;
          final namaBagian = bgMesin?['nama_bagian'] as String?;
          
          print('  - Asset: $namaAsset, Komponen: $namaKomponen, Bagian: $namaBagian');
          
          // Match berdasarkan nama asset dan (nama komponen atau nama bagian)
          if (namaAsset != null && 
              namaAsset.toLowerCase().trim() == namaInfrastruktur.toLowerCase().trim()) {
            final isMatch = (namaKomponen != null && 
                            namaKomponen.toLowerCase().trim() == section.bagian.toLowerCase().trim()) ||
                           (namaBagian != null && 
                            namaBagian.toLowerCase().trim() == section.bagian.toLowerCase().trim());
            
            if (isMatch) {
              selectedKomponen = komponen;
              print('✅ Komponen ditemukan!');
              break;
            }
          }
        }
        
        if (selectedKomponen == null) {
          // Buat daftar komponen yang tersedia untuk error message
          final availableKomponen = komponenAssets.map((k) {
            final bgMesin = k['bg_mesin'] as Map<String, dynamic>?;
            final asset = bgMesin?['assets'] as Map<String, dynamic>?;
            final namaAsset = asset?['nama_aset'] as String? ?? 
                             asset?['nama_assets'] as String? ?? 'Unknown';
            final namaKomponen = k['nama_komponen'] as String? ?? 'Unknown';
            return '$namaAsset - $namaKomponen';
          }).toList();
          
          throw Exception(
            'Komponen asset tidak ditemukan untuk: "$namaInfrastruktur - ${section.bagian}"\n\n'
            'Komponen yang tersedia:\n${availableKomponen.join('\n')}\n\n'
            'Pastikan nama infrastruktur dan bagian sesuai dengan data komponen assets yang ada.'
          );
        }
        
        // Handle ID type (bisa int atau String/UUID)
        final komponenIdRaw = selectedKomponen['id'];
        String komponenId;
        
        if (komponenIdRaw is String) {
          komponenId = komponenIdRaw;
        } else if (komponenIdRaw is int) {
          komponenId = komponenIdRaw.toString();
        } else {
          komponenId = komponenIdRaw.toString();
        }
        
        print('💾 Menyimpan template dengan komponen_id: $komponenId');
        final parsedPeriode = _parsePeriode(section.periode);
        final periodeEnum = _convertPeriodeToEnum(parsedPeriode['periode'] as String);
        
        // Simpan ke Supabase
        final template = await _repository.createTemplate(
          komponenAssetsId: komponenId,
          periode: periodeEnum,
          intervalPeriode: parsedPeriode['interval'] as int,
          jenisPekerjaan: section.jenisPekerjaan,
          stdPrwtn: section.standarPerawatan,
          alatBahan: section.alatBahan,
        );
        
        print('✅ Template berhasil dibuat dengan ID: ${template.id}');
        
        // Update local list
        _schedules.add(CheckSheetModel(
          no: startNo,
          namaInfrastruktur: namaInfrastruktur,
          bagian: section.bagian,
          periode: section.periode,
          jenisPekerjaan: section.jenisPekerjaan,
          standarPerawatan: section.standarPerawatan,
          alatBahan: section.alatBahan,
        ));
        
        // Simpan mapping
        if (template.id != null) {
          _noToTemplateIdMap[startNo] = template.id!;
        }
        startNo++;
      }
      
      print('✅ Semua schedule berhasil ditambahkan');
    } catch (e) {
      print('❌ Error adding schedule: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Update schedule dan simpan ke Supabase
  Future<void> updateSchedule(CheckSheetModel updatedSchedule) async {
    try {
      final templateId = _noToTemplateIdMap[updatedSchedule.no];
      if (templateId == null) {
        throw Exception('Template ID tidak ditemukan untuk schedule no ${updatedSchedule.no}');
      }

      final parsedPeriode = _parsePeriode(updatedSchedule.periode);
      final periodeEnum = _convertPeriodeToEnum(parsedPeriode['periode'] as String);
      
      // Update di Supabase
      await _repository.updateTemplate(
        templateId,
        periode: periodeEnum,
        intervalPeriode: parsedPeriode['interval'] as int,
        jenisPekerjaan: updatedSchedule.jenisPekerjaan,
        stdPrwtn: updatedSchedule.standarPerawatan,
        alatBahan: updatedSchedule.alatBahan,
      );

      // Update local list
      final index =
          _schedules.indexWhere((schedule) => schedule.no == updatedSchedule.no);
      if (index != -1) {
        _schedules[index] = updatedSchedule;
      }
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  /// Delete schedule dari Supabase
  Future<void> deleteSchedule(int no) async {
    try {
      final templateId = _noToTemplateIdMap[no];
      if (templateId == null) {
        throw Exception('Template ID tidak ditemukan untuk schedule no $no');
      }

      // Hapus dari Supabase (satu record = satu komponen)
      await _repository.deleteTemplate(templateId);

      // Hapus dari local list
      _schedules.removeWhere((schedule) => schedule.no == no);
      _noToTemplateIdMap.remove(no);

      // Re-number remaining schedules
      _renumberSchedules();
    } catch (e) {
      print('Error deleting schedule: $e');
      rethrow;
    }
  }

  /// Re-number schedules setelah delete
  void _renumberSchedules() {
    _schedules.sort((a, b) => a.no.compareTo(b.no));
    for (int i = 0; i < _schedules.length; i++) {
      final oldNo = _schedules[i].no;
      final newNo = i + 1;
      if (oldNo != newNo) {
        // Update mapping
        final templateId = _noToTemplateIdMap.remove(oldNo);
        if (templateId != null) {
          _noToTemplateIdMap[newNo] = templateId;
        }
        // Update no
        _schedules[i] = _schedules[i].copyWith(no: newNo);
      }
    }
  }
}

class CheckSheetSectionInput {
  final String bagian;
  final String periode;
  final String jenisPekerjaan;
  final String standarPerawatan;
  final String alatBahan;

  CheckSheetSectionInput({
    required this.bagian,
    required this.periode,
    required this.jenisPekerjaan,
    required this.standarPerawatan,
    required this.alatBahan,
  });
}
