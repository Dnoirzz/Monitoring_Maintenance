import 'package:shared/services/supabase_service.dart';

class MaintenanceRequestService {
  static final _client = SupabaseService.instance.client;

  /// Submit a new maintenance request
  static Future<void> submitRequest({
    required String requesterId,
    required String assetsId,
    required String judul,
    required String requestType,
    required String priority,
    required String keterangan,
  }) async {
    await _client.from('maintenance_request').insert({
      'requester_id': requesterId,
      'assets_id': assetsId,
      'judul': judul,
      'request_type': requestType,
      'priority': priority,
      'keterangan': keterangan,
      'status': 'Pending',
    });
  }

  /// Get maintenance requests with asset and requester info
  static Future<List<Map<String, dynamic>>> getRequests({
    String? requesterId,
  }) async {
    var query = _client
        .from('maintenance_request')
        .select('''
          id,
          judul,
          request_type,
          priority,
          keterangan,
          status,
          created_at,
          assets:assets_id (
            nama_assets,
            kode_assets
          ),
          requester:requester_id (
            full_name
          )
        ''');

    if (requesterId != null) {
      query = query.eq('requester_id', requesterId);
    }

    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
