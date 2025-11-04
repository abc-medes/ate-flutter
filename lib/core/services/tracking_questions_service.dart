// lib/core/services/tracking_questions_service.dart
import 'dart:async';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/api_service.dart';
import 'package:bodido/data/models/tracking_question_model.dart';

class TrackingQuestionsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<String>> listPendingQuestionIds(String userId,
      {int limit = 20}) async {
    try {
      final rows = await _client
          .from('user_question_bindings')
          .select('question_id')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .order('generated_for_body_state_at', ascending: false)
          .limit(limit);

      if (rows is! List) return <String>[];
      return rows
          .map((e) => (e as Map)['question_id']?.toString())
          .whereType<String>()
          .toList();
    } catch (e) {
      debugPrint('[TQS] listPendingQuestionIds error: $e');
      return <String>[];
    }
  }

  Future<List<TrackingQuestion>> getManyByIds(List<String> ids) async {
    if (ids.isEmpty) return <TrackingQuestion>[];
    try {
      final rows =
          await _client.from('llm_questions').select('*').inFilter('id', ids);

      if (rows is! List) return <TrackingQuestion>[];

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

  Future<List<TrackingQuestion>> getPendingOrGenerate({
    required String userId,
    String language = 'ko',
    String maxQuestions = '10',
    String optionsPerQuestion = '3',
    String goalFocus = 'general',
    Map<String, dynamic> trackingTargets = const {},
    int limit = 20,
    int retries = 3,
    Duration retryDelay = const Duration(milliseconds: 300),
  }) async {
    // 1) Try pending
    var ids = await listPendingQuestionIds(userId, limit: limit);
    if (ids.isNotEmpty) {
      return getManyByIds(ids);
    }

    // 2) Trigger generation (backend: generate-only)
    try {
      await ApiService.getOrGenerateTrackingQuestions(
        language: language,
        maxQuestions: maxQuestions,
        optionsPerQuestion: optionsPerQuestion,
        goalFocus: goalFocus,
        trackingTargets: trackingTargets,
      );
    } catch (e) {
      debugPrint('[TQS] generator call failed: $e');
    }

    // 3) Poll for rows written by backend
    for (var i = 0; i < retries; i++) {
      await Future.delayed(retryDelay);
      ids = await listPendingQuestionIds(userId, limit: limit);
      if (ids.isNotEmpty) {
        return getManyByIds(ids);
      }
    }

    return <TrackingQuestion>[];
  }
}

final trackingQuestionsServiceProvider =
    Provider<TrackingQuestionsService>((ref) => TrackingQuestionsService());
