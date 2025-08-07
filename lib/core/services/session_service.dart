import 'package:regene/common_libs.dart';
import 'package:uuid/uuid.dart';

final sessionIdProvider = StateProvider<String>((ref) => Uuid().v4());

// ... existing code ...

/// ─────────────────────────────────────────
/// SESSION IDS PROVIDER
/// ─────────────────────────────────────────

class ChatSessionInfo {
  final String sessionId;
  final DateTime firstMessageTime;
  final DateTime lastMessageTime;
  final int messageCount;

  ChatSessionInfo({
    required this.sessionId,
    required this.firstMessageTime,
    required this.lastMessageTime,
    required this.messageCount,
  });

  factory ChatSessionInfo.fromJson(Map<String, dynamic> json) {
    return ChatSessionInfo(
      sessionId: json['session_id'] as String,
      firstMessageTime: DateTime.parse(json['first_message_time'] as String),
      lastMessageTime: DateTime.parse(json['last_message_time'] as String),
      messageCount: json['message_count'] as int,
    );
  }
}

final chatSessionIdsProvider =
    FutureProvider.autoDispose<List<ChatSessionInfo>>(
  (ref) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in.');

    final response = await Supabase.instance.client.rpc(
      'get_chat_sessions_ordered',
      params: {'p_user_id': userId},
    );

    return (response as List)
        .map((item) => ChatSessionInfo.fromJson(item))
        .toList();
  },
);

final chatSessionIdsListProvider = Provider.autoDispose<List<String>>(
  (ref) {
    final sessionsAsync = ref.watch(chatSessionIdsProvider);
    return sessionsAsync.when(
      data: (sessions) => sessions.map((s) => s.sessionId).toList(),
      loading: () => <String>[],
      error: (_, __) => <String>[],
    );
  },
);
