import 'dart:async';

import 'package:regene/common_libs.dart';
import 'package:regene/data/models/chat_model.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => currentUser?.id;

  /// Fetch chat history for a session one time.
  Future<List<ChatMessageDTO>> getChatHistory(String sessionId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated to fetch chat history.');
    }

    final data = await _client
        .from('chat_history')
        .select()
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: true);

    final messages = data.map((item) {
      final dto = ChatMessageDTO.fromJson(item);
      return ChatMessageDTO(
        userId: dto.userId,
        createdAt: dto.createdAt,
        sessionId: dto.sessionId,
        message: dto.message,
        isUser: dto.isUser,
        clientLocalTimestamp: dto.clientLocalTimestamp ?? dto.createdAt,
        chatOffset: dto.chatOffset,
      );
    }).toList();

    return messages;
  }
}

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());
