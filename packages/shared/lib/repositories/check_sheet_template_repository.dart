import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/check_sheet_template_model.dart';
import '../services/supabase_service.dart';

/// Repository untuk CRUD operations pada tabel cek_sheet_template
class CheckSheetTemplateRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Get all check sheet templates dengan join ke komponen_assets, bg_mesin, dan assets
  Future<List<CheckSheetTemplateWithKomponen>> getAllTemplatesWithJoin() async {
    try {
      final response = await _client
          .from('cek_sheet_template')
          .select('''
            *,
            komponen_assets (
              *,
              bg_mesin (
                *,
                assets (*)
              ),
              assets (*)
            )
          ''')
          .order('created_at', ascending: false);

      print('📦 Response dari Supabase: ${response.length} templates');
      
      return (response as List).map((json) {
        // Debug: print struktur JSON untuk melihat data yang diterima
        print('📄 JSON keys: ${json.keys}');
        
        final template = CheckSheetTemplateModel.fromJson(json);
        final komponenAsset = json['komponen_assets'] as Map<String, dynamic>?;
        
        if (komponenAsset != null) {
          print('🔧 Komponen keys: ${komponenAsset.keys}');
        }
        
        final bagianMesin = komponenAsset?['bg_mesin'] as Map<String, dynamic>?;
        
        if (bagianMesin != null) {
          print('📦 Bagian mesin keys: ${bagianMesin.keys}');
        }
        
        // Coba ambil asset dari bg_mesin dulu, jika tidak ada coba dari komponen_assets langsung
        var asset = bagianMesin?['assets'] as Map<String, dynamic>?;
        if (asset == null) {
          // Fallback: ambil dari direct relationship komponen_assets -> assets
          asset = komponenAsset?['assets'] as Map<String, dynamic>?;
        }

        // Debug: print untuk melihat struktur data
        if (asset != null) {
          print('🏭 Asset keys: ${asset.keys}');
          print('🏭 Asset ditemukan: ${asset['nama_assets']}');
        } else {
          print('⚠️ Asset is null untuk template ${template.id}');
          print('   Komponen ID: ${komponenAsset?['id']}');
          print('   Bagian mesin ID: ${bagianMesin?['id']}');
        }

        return CheckSheetTemplateWithKomponen(
          template: template,
          komponenAsset: komponenAsset,
          bagianMesin: bagianMesin,
          asset: asset,
        );
      }).toList();
    } catch (e) {
      print('❌ Error getAllTemplatesWithJoin: $e');
      throw Exception('Gagal mengambil data template: $e');
    }
  }

  /// Get all check sheet templates (tanpa join)
  Future<List<CheckSheetTemplateModel>> getAllTemplates() async {
    try {
      final response = await _client
          .from('cek_sheet_template')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CheckSheetTemplateModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data template: $e');
    }
  }

  /// Get template by ID
  Future<CheckSheetTemplateModel?> getTemplateById(String id) async {
    try {
      final response = await _client
          .from('cek_sheet_template')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return CheckSheetTemplateModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil template: $e');
    }
  }

  /// Get template by ID dengan join
  Future<CheckSheetTemplateWithKomponen?> getTemplateByIdWithJoin(String id) async {
    try {
      final response = await _client
          .from('cek_sheet_template')
          .select('''
            *,
            komponen_assets (
              *,
              bg_mesin (
                *,
                assets (*)
              )
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      final template = CheckSheetTemplateModel.fromJson(response);
      final komponenAsset = response['komponen_assets'] as Map<String, dynamic>?;
      final bagianMesin = komponenAsset?['bg_mesin'] as Map<String, dynamic>?;
      final asset = bagianMesin?['assets'] as Map<String, dynamic>?;

      return CheckSheetTemplateWithKomponen(
        template: template,
        komponenAsset: komponenAsset,
        bagianMesin: bagianMesin,
        asset: asset,
      );
    } catch (e) {
      throw Exception('Gagal mengambil template: $e');
    }
  }

  /// Create new template
  Future<CheckSheetTemplateModel> createTemplate({
    required String komponenAssetsId,
    String? periode,
    String? jenisPekerjaan,
    String? stdPrwtn,
    String? alatBahan,
    int? intervalPeriode,
  }) async {
    try {
      print('📝 Creating template dengan data:');
      print('  - komponen_assets_id: $komponenAssetsId');
      print('  - periode: $periode');
      print('  - interval_periode: $intervalPeriode');
      print('  - jenis_pekerjaan: $jenisPekerjaan');
      print('  - std_prwtn: $stdPrwtn');
      print('  - alat_bahan: $alatBahan');
      
      final Map<String, dynamic> data = {
        'komponen_assets_id': komponenAssetsId,
        if (periode != null) 'periode': periode,
        if (jenisPekerjaan != null && jenisPekerjaan.isNotEmpty) 'jenis_pekerjaan': jenisPekerjaan,
        if (stdPrwtn != null && stdPrwtn.isNotEmpty) 'std_prwtn': stdPrwtn,
        if (alatBahan != null && alatBahan.isNotEmpty) 'alat_bahan': alatBahan,
        if (intervalPeriode != null) 'interval_periode': intervalPeriode,
      };

      print('📤 Mengirim data ke Supabase...');
      final response = await _client
          .from('cek_sheet_template')
          .insert(data)
          .select()
          .single();

      print('✅ Response dari Supabase: $response');
      return CheckSheetTemplateModel.fromJson(response);
    } catch (e, stackTrace) {
      print('❌ Error creating template: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Gagal membuat template: $e');
    }
  }

  /// Update existing template
  Future<CheckSheetTemplateModel> updateTemplate(
    String id, {
    String? komponenAssetsId,
    String? periode,
    String? jenisPekerjaan,
    String? stdPrwtn,
    String? alatBahan,
    int? intervalPeriode,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (komponenAssetsId != null) {
        data['komponen_assets_id'] = komponenAssetsId;
      }
      if (periode != null) {
        data['periode'] = periode;
      }
      if (jenisPekerjaan != null) {
        data['jenis_pekerjaan'] = jenisPekerjaan;
      }
      if (stdPrwtn != null) {
        data['std_prwtn'] = stdPrwtn;
      }
      if (alatBahan != null) {
        data['alat_bahan'] = alatBahan;
      }
      if (intervalPeriode != null) {
        data['interval_periode'] = intervalPeriode;
      }

      final response = await _client
          .from('cek_sheet_template')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return CheckSheetTemplateModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate template: $e');
    }
  }

  /// Delete template
  Future<void> deleteTemplate(String id) async {
    try {
      await _client.from('cek_sheet_template').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus template: $e');
    }
  }

  /// Get komponen assets untuk dropdown
  /// Mengambil dari tabel komponen_assets (bukan bg_mesin)
  Future<List<Map<String, dynamic>>> getKomponenAssets() async {
    try {
      final response = await _client
          .from('komponen_assets')
          .select('''
            *,
            bg_mesin (
              *,
              assets (*)
            ),
            assets (*)
          ''')
          .order('created_at', ascending: false);

      print('📦 Total komponen_assets: ${(response as List).length}');
      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error getKomponenAssets: $e');
      throw Exception('Gagal mengambil komponen assets: $e');
    }
  }
  
  /// Get komponen assets berdasarkan asset ID
  /// Mengambil dari tabel komponen_assets yang terkait dengan asset tertentu
  Future<List<Map<String, dynamic>>> getKomponenByAssetId(String assetId) async {
    try {
      // Ambil semua komponen dengan join, lalu filter manual
      // Karena Supabase PostgREST tidak support filter complex nested relationship dengan mudah
      final allKomponen = await getKomponenAssets();
      
      final filtered = allKomponen.where((komponen) {
        // Cek via bg_mesin -> assets
        final bgMesin = komponen['bg_mesin'] as Map<String, dynamic>?;
        final asset = bgMesin?['assets'] as Map<String, dynamic>?;
        final assetIdFromKomponen = asset?['id']?.toString();
        
        // Juga cek direct relationship komponen_assets -> assets (jika ada)
        final assetDirect = komponen['assets'] as Map<String, dynamic>?;
        final assetIdDirect = assetDirect?['id']?.toString();
        
        final matches = assetIdFromKomponen == assetId || assetIdDirect == assetId;
        if (matches) {
          print('✅ Komponen ${komponen['id']} match dengan asset $assetId');
        }
        return matches;
      }).toList();

      print('📦 Komponen untuk asset $assetId: ${filtered.length} dari ${allKomponen.length} total');
      return filtered;
    } catch (e) {
      print('❌ Error getKomponenByAssetId: $e');
      rethrow;
    }
  }
}
