import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/core/services/chat_service.dart';
import 'package:regene/data/models/chat_model.dart';

final chatViewModelProvider = StateNotifierProvider.autoDispose
    .family<ChatViewModel, ChatViewState, ChatMessage>(
  (ref, cm) => ChatViewModel(ref, cm)..loadChatHistory(ref),
);

/// ─────────────────────────────────────────
/// STATE
/// ─────────────────────────────────────────
class ChatViewState {
  final List<ChatMessage> messages;
  final List<ChatMessageDTO> prevMessages;
  final bool isProcessing;

  const ChatViewState({
    this.messages = const [],
    this.prevMessages = const [],
    this.isProcessing = false,
  });

  ChatViewState copyWith({
    List<ChatMessage>? messages,
    List<ChatMessageDTO>? prevMessages,
    bool? isProcessing,
  }) =>
      ChatViewState(
        messages: messages ?? this.messages,
        prevMessages: prevMessages ?? this.prevMessages,
        isProcessing: isProcessing ?? this.isProcessing,
      );
}

/// ─────────────────────────────────────────
/// VIEW-MODEL
/// ─────────────────────────────────────────
class ChatViewModel extends StateNotifier<ChatViewState> {
  ChatViewModel(Ref ref, ChatMessage initialPrompt)
      : super(const ChatViewState()) {
    sessionId = initialPrompt.sessionId;

    _sendPrompt(initialPrompt);
  }

  late final String sessionId;
  StreamSubscription<String>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _sendPrompt(ChatMessage cm) {
    if (cm.message.trim().isEmpty || state.isProcessing) return;

    final aiMsgPlaceholder = ChatMessage(
      sessionId: sessionId,
      message: '',
      isUser: false,
      chatOffset: cm.chatOffset,
    );

    state = state.copyWith(
      messages: [...state.messages, cm, aiMsgPlaceholder],
      isProcessing: true,
    );
    final aiMessageIndex = state.messages.length - 1;

    _sub = ApiService.sendChatMessage(cm).listen(
      (chunk) {
        final currentMessages = List<ChatMessage>.from(state.messages);
        final currentAiMessage = currentMessages[aiMessageIndex];
        currentMessages[aiMessageIndex] = currentAiMessage.copyWith(
          message: currentAiMessage.message + chunk,
        );
        state = state.copyWith(messages: currentMessages);
      },
      onDone: () {
        state = state.copyWith(isProcessing: false);
      },
      onError: (e) {
        final currentMessages = List<ChatMessage>.from(state.messages);
        final currentAiMessage = currentMessages[aiMessageIndex];
        currentMessages[aiMessageIndex] = currentAiMessage.copyWith(
          message: '⚠︎ Error: $e',
        );
        state = state.copyWith(
          messages: currentMessages,
          isProcessing: false,
        );
      },
    );
  }

  void loadChatHistory(Ref ref) async {
    final history =
        await ref.read(chatServiceProvider).getChatHistory(sessionId);
    print('history: $history');
    state = state.copyWith(prevMessages: history);
  }
}

/// ─────────────────────────────────────────
/// PROVIDER (prompt 파라미터 전달)
/// ─────────────────────────────────────────
