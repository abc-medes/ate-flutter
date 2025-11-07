import 'dart:convert';

final _qCardRe = RegExp(r'```question-card\s+([\s\S]*?)```', multiLine: true);

Map<String, dynamic>? parseQuestionCardBlock(String s) {
  final m = _qCardRe.firstMatch(s);
  if (m == null) return null;
  try {
    return jsonDecode(m.group(1)!);
  } catch (_) {
    return null;
  }
}

String stripQuestionCardBlock(String s) => s.replaceAll(_qCardRe, '').trim();
