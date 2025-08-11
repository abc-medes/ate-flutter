import 'dart:async';

import 'package:regene/common_libs.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/data/models/chat_model.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  StreamSubscription<String>? _sub;

  Future<List<ChatMessageDTO>> getChatHistory() async {
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

  void sendPrompt(
    ChatMessageDTO message, {
    required Function(ChatMessageDTO) onChunk,
    required VoidCallback onDone,
    required Function(String) onError,
  }) {
    if (message.message?.trim().isEmpty == true) return;

    // Create AI message placeholder
    final aiMessage = ChatMessageDTO(
      userId: currentUserId!,
      sessionId: message.sessionId,
      message: '',
      isUser: false,
      createdAt: DateTime.now(),
      clientLocalTimestamp: DateTime.now(),
      chatOffset: message.chatOffset ?? 0,
    );

    // Start streaming response
    _sub = ApiService.sendChatMessage(message).listen(
      (chunk) {
        // Update the AI message with the chunk
        final updatedAiMessage = aiMessage.copyWith(
          message: (aiMessage.message ?? '') + chunk,
        );
        onChunk(updatedAiMessage);
      },
      onDone: () {
        _sub?.cancel();
        onDone();
      },
      onError: (e) {
        _sub?.cancel();
        final errorMessage = aiMessage.copyWith(
          message: '⚠︎ Error: $e',
        );
        onChunk(errorMessage);
        onError(e.toString());
      },
    );
  }
}

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());
