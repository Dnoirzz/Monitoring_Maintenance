import '../model/karyawan_model.dart';
import 'supabase_service.dart';

class KaryawanService {
  final _client = SupabaseService.client;

  Future<List<KaryawanModel>> getAllKaryawan() async {
    try {
      final response = await _client.from('karyawan').select();
      return (response as List<dynamic>)
          .map((item) => KaryawanModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting karyawan: $e');
      return [];
    }
  }

  Future<KaryawanModel?> getKaryawanById(String id) async {
    try {
      final response = await _client.from('karyawan').select().eq('id', id).single();
      return KaryawanModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error getting karyawan by id: $e');
      return null;
    }
  }

  Future<KaryawanModel?> getKaryawanByEmail(String email) async {
    try {
      final response = await _client.from('karyawan').select().eq('email', email).single();
      return KaryawanModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error getting karyawan by email: $e');
      return null;
    }
  }

  Future<KaryawanModel?> createKaryawan(KaryawanModel karyawan) async {
    try {
      final response =
          await _client.from('karyawan').insert(karyawan.toMap()).select().single();
      return KaryawanModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating karyawan: $e');
      return null;
    }
  }

  Future<KaryawanModel?> updateKaryawan(KaryawanModel karyawan) async {
    try {
      if (karyawan.id == null) return null;
      final response = await _client
          .from('karyawan')
          .update(karyawan.toMap())
          .eq('id', karyawan.id!)
          .select()
          .single();
      return KaryawanModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error updating karyawan: $e');
      return null;
    }
  }

  Future<bool> deleteKaryawan(String id) async {
    try {
      await _client.from('karyawan').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting karyawan: $e');
      return false;
    }
  }

  // Get user assets (mesin yang dikerjakan)
  Future<List<String>> getMesinByKaryawanId(String karyawanId) async {
    try {
      final response = await _client
          .from('user_assets')
          .select('assets_id, assets(nama_assets)')
          .eq('karyawan_id', karyawanId);
      
      final List<String> mesinList = [];
      for (var item in response as List) {
        final assets = item['assets'] as Map<String, dynamic>?;
        if (assets != null && assets['nama_assets'] != null) {
          mesinList.add(assets['nama_assets'] as String);
        }
      }
      return mesinList;
    } catch (e) {
      print('Error getting mesin by karyawan id: $e');
      return [];
    }
  }
}

