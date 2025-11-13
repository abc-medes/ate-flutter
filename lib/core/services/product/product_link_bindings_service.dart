import 'package:bodido/common_libs.dart';

class ProductLinkBindingsService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'product_link_bindings';

  Future<List<Map<String, dynamic>>> getByBindingKeys(List<String> keys) async {
    if (keys.isEmpty) return <Map<String, dynamic>>[];
    final rows = await _client
        .from(_table)
        .select('binding_key, affiliate_url, affiliate_html, merchant')
        .inFilter('binding_key', keys);
    return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>?> getByBindingKey(String key) async {
    final row = await _client
        .from(_table)
        .select('binding_key, affiliate_url, affiliate_html, merchant')
        .eq('binding_key', key)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row as Map);
  }
}

final productLinkBindingsServiceProvider =
    Provider<ProductLinkBindingsService>((ref) => ProductLinkBindingsService());
