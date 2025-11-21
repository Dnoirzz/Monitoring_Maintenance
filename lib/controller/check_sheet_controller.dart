import '../model/check_sheet_model.dart';

class CheckSheetController {
  final List<CheckSheetModel> _schedules = [];

  void initializeSampleData() {
    _schedules.clear();
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

  void addSchedulesFromForm({
    required String namaInfrastruktur,
    required List<CheckSheetSectionInput> bagianItems,
  }) {
    for (var section in bagianItems) {
      _schedules.add(CheckSheetModel(
        no: _schedules.length + 1,
        namaInfrastruktur: namaInfrastruktur,
        bagian: section.bagian,
        periode: section.periode,
        jenisPekerjaan: section.jenisPekerjaan,
        standarPerawatan: section.standarPerawatan,
        alatBahan: section.alatBahan,
      ));
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

