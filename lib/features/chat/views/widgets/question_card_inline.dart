import 'package:bodido/core/services/api_service.dart';
import 'package:bodido/data/models/tracking_question_model.dart';
import 'package:flutter/material.dart';

class QuestionCardInline extends StatelessWidget {
  final Map<String, dynamic> card;
  final String sessionId;

  const QuestionCardInline({
    super.key,
    required this.card,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final questions = (card['questions'] as List?) ?? const [];
    if (questions.isEmpty) return const SizedBox.shrink();

    final q = Map<String, dynamic>.from(questions.first);
    final qId = (q['question_id'] ?? q['id'] ?? '').toString();
    final qTag = (q['question_tag'] ?? 'general').toString();
    final opts = (q['options'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return Card(
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q['question']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in opts)
                  ElevatedButton(
                    onPressed: () async {
                      final req = UserSelectionRequest(
                        questionId: qId,
                        questionTag: qTag,
                        optionId: (o['option_id'] ?? o['id']).toString(),
                        selectionKey: (o['selection_key'] ?? '').toString(),
                        sessionId: sessionId,
                        clientLocalTimestamp: DateTime.now(),
                      );
                      await ApiService.selectTrackingOption(request: req);
                      // Optionally: disable buttons, show a short confirmation, or append feedback.
                    },
                    child: Text((o['label'] ?? '').toString()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
