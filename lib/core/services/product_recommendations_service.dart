import 'dart:async';
import 'package:bodido/common_libs.dart';

class ProductRecommendationsService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => currentUser?.id;

  static const String _table = 'product_recommendations';

  Future<List<Map<String, dynamic>>> listForCurrentUser(
      {int limit = 50}) async {
    try {
      if (currentUserId == null) {
        throw Exception(
            'User not authenticated to fetch product recommendations.');
      }

      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', currentUserId!)
          .order('created_at', ascending: false)
          .limit(limit);

      return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('[PRS] listForCurrentUser error: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> listAll({int limit = 100}) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('[PRS] listAll error: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<Map<String, dynamic>?> getById(dynamic id) async {
    try {
      final data =
          await _client.from(_table).select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      debugPrint('[PRS] getById error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> upsert(Map<String, dynamic> record) async {
    try {
      final rows = await _client.from(_table).upsert(record).select().limit(1);
      if (rows.isEmpty) return null;
      return Map<String, dynamic>.from(rows.first as Map);
    } catch (e) {
      debugPrint('[PRS] upsert error: $e');
      return null;
    }
  }

  Future<bool> deleteById(dynamic id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[PRS] deleteById error: $e');
      return false;
    }
  }
}

final productRecommendationsServiceProvider =
    Provider<ProductRecommendationsService>(
  (ref) => ProductRecommendationsService(),
);
