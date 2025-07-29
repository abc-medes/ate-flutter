import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/core/services/chat_service.dart';
import 'package:regene/core/services/session_service.dart';
import 'package:regene/data/models/chat_model.dart';

final chatViewModelProvider =
    StateNotifierProvider.autoDispose<ChatViewModel, ChatViewState>(
  (ref) => ChatViewModel(ref),
);

/// ─────────────────────────────────────────
/// STATE
/// ─────────────────────────────────────────
class ChatViewState {
  final Map<String, List<ChatMessage>> historicalSessions;
  final List<String> orderedSessionIds;
  final List<ChatMessage> currentSessionMessages;

  final bool isProcessing;
  final String? error;

  const ChatViewState({
    this.historicalSessions = const {},
    this.orderedSessionIds = const [],
    this.currentSessionMessages = const [],
    this.isProcessing = false,
    this.error,
  });

  ChatViewState copyWith({
    Map<String, List<ChatMessage>>? historicalSessions,
    List<String>? orderedSessionIds,
    List<ChatMessage>? currentSessionMessages,
    bool? isProcessing,
    String? error,
    bool clearError = false,
  }) {
    return ChatViewState(
      historicalSessions: historicalSessions ?? this.historicalSessions,
      orderedSessionIds: orderedSessionIds ?? this.orderedSessionIds,
      currentSessionMessages:
          currentSessionMessages ?? this.currentSessionMessages,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// ─────────────────────────────────────────
/// VIEW-MODEL
/// ─────────────────────────────────────────
class ChatViewModel extends StateNotifier<ChatViewState> {
  ChatViewModel(this._ref) : super(const ChatViewState()) {}

  final Ref _ref;
  StreamSubscription<String>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void sendPrompt(ChatMessage cm) {
    if (cm.message.trim().isEmpty || state.isProcessing) return;

    final aiMsgPlaceholder = ChatMessage(
      sessionId: _ref.read(sessionIdProvider),
      message: '',
      isUser: false,
      chatOffset: cm.chatOffset,
    );

    if (!mounted) return;
    state = state.copyWith(
      currentSessionMessages: [
        ...state.currentSessionMessages,
        cm,
        aiMsgPlaceholder
      ],
      isProcessing: true,
      clearError: true,
    );

    _sub = ApiService.sendChatMessage(cm).listen(
      (chunk) {
        if (!mounted) return;
        final messages = List<ChatMessage>.from(state.currentSessionMessages);
        final aiMessageIndex = messages.length - 1;
        if (aiMessageIndex < 0) return;
        final currentAiMessage = messages[aiMessageIndex];
        messages[aiMessageIndex] = currentAiMessage.copyWith(
          message: currentAiMessage.message + chunk,
        );
        state = state.copyWith(currentSessionMessages: messages);
      },
      onDone: () {
        if (!mounted) return;
        state = state.copyWith(isProcessing: false);
      },
      onError: (e) {
        if (!mounted) return;
        final messages = List<ChatMessage>.from(state.currentSessionMessages);
        final aiMessageIndex = messages.length - 1;

        if (aiMessageIndex < 0) {
          if (!mounted) return;
          state = state.copyWith(
            isProcessing: false,
            error: 'Error sending message: $e',
          );
          return;
        }

        final currentAiMessage = messages[aiMessageIndex];
        messages[aiMessageIndex] = currentAiMessage.copyWith(
          message: '⚠︎ Error: $e',
        );
        if (!mounted) return;
        state = state.copyWith(
          currentSessionMessages: messages,
          isProcessing: false,
          error: 'Error sending message: $e',
        );
      },
    );
  }
}

/// ─────────────────────────────────────────
/// PROVIDER (prompt 파라미터 전달)
/// ─────────────────────────────────────────
