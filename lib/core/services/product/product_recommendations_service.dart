import 'dart:async';
import 'package:bodido/common_libs.dart';

class ProductRecommendationsService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'product_recommendations';

  Future<Map<String, dynamic>?> getByUserIdSingle(String userId) async {
    final row =
        await _client.from(_table).select().eq('user_id', userId).maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row as Map);
  }

  Future<List<Map<String, dynamic>>> listAll({int limit = 100}) async {
    final rows = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>?> getById(dynamic id) async {
    final data = await _client.from(_table).select().eq('id', id).maybeSingle();
    return data == null ? null : Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>?> upsert(Map<String, dynamic> record) async {
    final rows = await _client.from(_table).upsert(record).select().limit(1);
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first as Map);
  }

  Future<bool> deleteById(dynamic id) async {
    await _client.from(_table).delete().eq('id', id);
    return true;
  }
}

final productRecommendationsServiceProvider =
    Provider<ProductRecommendationsService>(
  (ref) => ProductRecommendationsService(),
);
