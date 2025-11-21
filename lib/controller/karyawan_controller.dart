import '../model/karyawan_model.dart';

class KaryawanController {
  List<KaryawanModel> _karyawan = [];

  // Initialize with sample data
  void initializeSampleData() {
    _karyawan = [
      KaryawanModel(
        nama: "Ramadhan F",
        mesin: "Creeper 1",
        telp: "08123456789",
        email: "ramadhan@example.com",
        password: "******",
      ),
      KaryawanModel(
        nama: "Adityo Saputro",
        mesin: "Mixing Machine",
        telp: "087812345678",
        email: "adityo@example.com",
        password: "******",
      ),
      KaryawanModel(
        nama: "Rama Wijaya",
        mesin: "Creeper 2",
        telp: "085312345678",
        email: "rama@example.com",
        password: "******",
      ),
    ];
  }

  List<KaryawanModel> getAllKaryawan() {
    return List.unmodifiable(_karyawan);
  }

  List<KaryawanModel> filterKaryawan({
    String? mesin,
    String? searchQuery,
  }) {
    List<KaryawanModel> filtered = List.from(_karyawan);

    // Filter by mesin
    if (mesin != null && mesin.isNotEmpty) {
      filtered = filtered.where((k) => k.mesin == mesin).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((k) {
        return k.nama.toLowerCase().contains(query) ||
            k.mesin.toLowerCase().contains(query) ||
            k.telp.toLowerCase().contains(query) ||
            k.email.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  List<String> getMesinList() {
    Set<String> mesinSet = {};
    for (var karyawan in _karyawan) {
      mesinSet.add(karyawan.mesin);
    }
    return mesinSet.toList()..sort();
  }

  void addKaryawan(KaryawanModel karyawan) {
    _karyawan.add(karyawan);
  }

  void deleteKaryawan(String nama) {
    _karyawan.removeWhere((k) => k.nama == nama);
  }

  void updateKaryawan(String nama, KaryawanModel updatedKaryawan) {
    final index = _karyawan.indexWhere((k) => k.nama == nama);
    if (index != -1) {
      _karyawan[index] = updatedKaryawan;
    }
  }
}

