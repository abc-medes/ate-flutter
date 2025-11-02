import 'dart:async';
import 'dart:convert';

import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/tracking_question_model.dart';

class TrackingQuestionsService {
  final SupabaseClient _client = Supabase.instance.client;

  // Existing: fetch the user's bindings
  Future<List<UserQuestionBinding>> fetchUserBindings() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      debugPrint(
          '[TrackingQuestionsService] Not authenticated; skipping fetch');
      return [];
    }

    final rows = await _client
        .from('user_question_bindings')
        .select('*')
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(200);

    return (rows as List)
        .map((e) => UserQuestionBinding.fromJson(
              e is Map<String, dynamic>
                  ? e
                  : Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  // New: fetch user's questions with options from llm_questions
  Future<List<TrackingQuestion>> fetchUserQuestionsWithOptions(
      {int limit = 50}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      debugPrint(
          '[TrackingQuestionsService] Not authenticated; skipping fetch');
      return [];
    }

    // 1) Get the latest bound question IDs for this user
    final bindingsRows = await _client
        .from('user_question_bindings')
        .select('question_id')
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);

    final ids = (bindingsRows as List)
        .map((e) => (e as Map)['question_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    if (ids.isEmpty) return [];

    // 2) Fetch corresponding questions from llm_questions
    final qRows =
        await _client.from('llm_questions').select('*').inFilter('id', ids);

    final questions = (qRows as List)
        .map((e) =>
            e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
        .map((m) {
      final v = Map<String, dynamic>.from(m);

      // options is stored as a JSON string; parse to List for model
      final raw = v['options'];
      if (raw is String && raw.isNotEmpty) {
        try {
          v['options'] = jsonDecode(raw);
        } catch (_) {
          v['options'] = const [];
        }
      } else if (raw == null) {
        v['options'] = const [];
      }

      // Ensure a default for question_tag if missing
      v['question_tag'] = v['question_tag']?.toString() ?? 'general';

      return TrackingQuestion.fromJson(v);
    }).toList();

    // 3) Preserve order by latest bindings
    final indexById = {for (var i = 0; i < ids.length; i++) ids[i]: i};
    questions.sort((a, b) {
      final ai = indexById[a.id] ?? 1 << 30;
      final bi = indexById[b.id] ?? 1 << 30;
      return ai.compareTo(bi);
    });

    return questions;
  }
}

// Provider
final trackingQuestionsServiceProvider =
    Provider<TrackingQuestionsService>((ref) => TrackingQuestionsService());
