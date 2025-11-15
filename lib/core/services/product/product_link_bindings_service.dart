import 'package:bodido/common_libs.dart';

class ProductLinkBindingsService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'product_link_bindings';
  static const _cols =
      'id, binding_id, normalized_title, affiliate_url, affiliate_html, merchant, updated_at, created_at';

  Future<List<Map<String, dynamic>>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return <Map<String, dynamic>>[];
    final rows = await _client.from(_table).select(_cols).inFilter('id', ids);
    return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    if (id.isEmpty) return null;
    final row =
        await _client.from(_table).select(_cols).eq('id', id).maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row as Map);
  }

  // (Optional) keep existing key-based methods if used elsewhere
  Future<List<Map<String, dynamic>>> getByBindingKeys(List<String> keys) async {
    if (keys.isEmpty) return <Map<String, dynamic>>[];
    final rows =
        await _client.from(_table).select(_cols).inFilter('binding_id', keys);
    return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}

final productLinkBindingsServiceProvider =
    Provider<ProductLinkBindingsService>((ref) => ProductLinkBindingsService());
