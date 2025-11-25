import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class SupabaseStorageService {
  final SupabaseClient _client = SupabaseService.instance.client;
  // Update nama bucket sesuai screenshot (plural 'assets')
  // Jika masih error, coba ganti jadi 'ASSETS-IMAGES' (huruf besar semua)
  static const String _bucketName = 'assets-images';

  /// Uploads an image to Supabase Storage from XFile (Cross-Platform: Web, Android, iOS).
  /// Returns the public URL.
  Future<String?> uploadAssetImage(XFile imageFile) async {
    try {
      // 1. Sanitize filename (PENTING: Hindari spasi/karakter unik)
      final String sanitizedFileName = imageFile.name.replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );
      final String fileName =
          'asset_${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';

      final Uint8List bytes = await imageFile.readAsBytes();

      // 2. Determine Content-Type (Optional, good for browser preview)
      String contentType = 'application/octet-stream';
      final nameLower = imageFile.name.toLowerCase();
      if (nameLower.endsWith('.jpg') || nameLower.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (nameLower.endsWith('.png')) {
        contentType = 'image/png';
      }

      // 3. Upload binary (support Web & Mobile)
      await _client.storage
          .from(_bucketName)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: contentType,
            ),
          );

      // 4. Get Public URL
      final String publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      // Print error ke console untuk debugging
      print('❌ Error Upload: $e');
      throw Exception(
        'Gagal upload gambar. Pastikan Policy bucket "asset-images" sudah Public Upload. Error: $e',
      );
    }
  }
}
