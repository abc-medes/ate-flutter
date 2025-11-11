// lib/core/services/tracking_questions_service.dart
import 'dart:async';

import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/tracking_question_model.dart';

class TrackingQuestionsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<UserQuestionBinding>> listQuestionBindings(
    String userId, {
    int limit = 10,
    List<BindingStatus>? statuses,
    Set<String> excludeQuestionIds = const {},
  }) async {
    try {
      final effectiveLimit = limit + excludeQuestionIds.length;

      var query = _client
          .from('user_question_bindings')
          .select(
              'question_id, status, option_id, answered_at, generated_for_body_state_at')
          .eq('user_id', userId);

      if (statuses != null && statuses.isNotEmpty) {
        query = query.inFilter('status', statuses.map((s) => s.name).toList());
      }

      final rows = await query
          .order('answered_at', ascending: false)
          .order('generated_for_body_state_at', ascending: false)
          .limit(effectiveLimit);

      final list = <UserQuestionBinding>[];
      for (final r in rows) {
        final m = Map<String, dynamic>.from(r as Map);
        final qid = m['question_id']?.toString();
        if (qid == null || excludeQuestionIds.contains(qid)) continue;

        list.add(UserQuestionBinding.fromJson(m));
        if (list.length >= limit) break;
      }
      return list;
    } catch (e) {
      debugPrint('[TQS] listQuestionBindings error: $e');
      return <UserQuestionBinding>[];
    }
  }

  Future<List<String>> listQuestionIds(
    String userId, {
    int limit = 20,
    List<String>? statuses,
  }) async {
    try {
      var query = _client
          .from('user_question_bindings')
          .select('question_id')
          .eq('user_id', userId);

      if (statuses != null && statuses.isNotEmpty) {
        query = query.inFilter('status', statuses);
      }

      final rows = await query
          .order('generated_for_body_state_at', ascending: false)
          .limit(limit);

      return rows
          .map((e) => (e as Map)['question_id']?.toString())
          .whereType<String>()
          .toList();
    } catch (e) {
      debugPrint('[TQS] listQuestionIds error: $e');
      return <String>[];
    }
  }

  Future<List<TrackingQuestion>> getManyByIds(List<String> ids) async {
    if (ids.isEmpty) return <TrackingQuestion>[];
    try {
      final rows =
          await _client.from('llm_questions').select('*').inFilter('id', ids);

      final list = rows
          .map((e) =>
              TrackingQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      // Preserve original order of ids
      final pos = <String, int>{for (var i = 0; i < ids.length; i++) ids[i]: i};
      list.sort(
          (a, b) => (pos[a.id] ?? 1 << 30).compareTo(pos[b.id] ?? 1 << 30));
      return list;
    } catch (e) {
      debugPrint('[TQS] getManyByIds error: $e');
      return <TrackingQuestion>[];
    }
  }

  Future<Map<String, String>> listSelectedOptionsMap(
    String userId, {
    List<String>? questionIds,
    int limit = 100,
  }) async {
    try {
      var query = _client
          .from('user_question_bindings')
          .select('question_id, option_id, answered_at')
          .eq('user_id', userId)
          .eq('status', 'selected')
          .inFilter('question_id', questionIds ?? [])
          .order('answered_at', ascending: false);

      final rows = await query.limit(limit);

      final out = <String, String>{};
      for (final r in rows) {
        final m = Map<String, dynamic>.from(r as Map);
        final qid = m['question_id']?.toString();
        final oid = m['option_id']?.toString();
        if (qid == null || oid == null) continue;
        out.putIfAbsent(qid, () => oid);
      }
      return out;
    } catch (e) {
      debugPrint('[TQS] listSelectedOptionsMap error: $e');
      return <String, String>{};
    }
  }

  Future<List<TrackingQuestion>> listQuestionsByUserAndSession({
    required String userId,
    required String sessionId,
    int limit = 50,
  }) async {
    try {
      final rows = await _client
          .from('user_question_bindings')
          .select('question_id')
          .eq('user_id', userId)
          .eq('session_id', sessionId)
          .order('answered_at', ascending: false)
          .order('generated_for_body_state_at', ascending: false)
          .limit(limit);

      final ids = rows
          .map((e) => (e as Map)['question_id']?.toString())
          .whereType<String>()
          .toList();

      if (ids.isEmpty) return <TrackingQuestion>[];

      final questions = await getManyByIds(ids);

      debugPrint('[TQS] list once user=$userId session=$sessionId '
          'count=${questions.length} ids=${questions.map((q) => q.id).join(', ')}');

      return questions;
    } catch (e) {
      debugPrint('[TQS] listQuestionsByUserAndSession error: $e');
      return <TrackingQuestion>[];
    }
  }
}

final trackingQuestionsServiceProvider =
    Provider<TrackingQuestionsService>((ref) => TrackingQuestionsService());
