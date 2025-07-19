import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/data/models/chat_model.dart';

/// ─────────────────────────────────────────
/// STATE
/// ─────────────────────────────────────────
class ChatViewState {
  final List<ChatMessage> messages;
  final bool isProcessing;

  const ChatViewState({
    this.messages = const [],
    this.isProcessing = false,
  });

  ChatViewState copyWith({
    List<ChatMessage>? messages,
    bool? isProcessing,
  }) =>
      ChatViewState(
        messages: messages ?? this.messages,
        isProcessing: isProcessing ?? this.isProcessing,
      );
}

/// ─────────────────────────────────────────
/// VIEW-MODEL
/// ─────────────────────────────────────────
class ChatViewModel extends StateNotifier<ChatViewState> {
  ChatViewModel(this._initialPrompt) : super(const ChatViewState()) {
    _sendPrompt(_initialPrompt); // 화면 진입 시 바로 전송
  }

  final String _initialPrompt;
  StreamSubscription<String>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _sendPrompt(String text) {
    if (text.trim().isEmpty || state.isProcessing) return;

    // 1) 사용자 메시지
    final userMsg = ChatMessage(text: text, isUser: true);

    // 2) AI 자리 확보(빈 메시지)
    var aiMsg = ChatMessage(text: '', isUser: false);

    state = state.copyWith(
      messages: [...state.messages, userMsg, aiMsg],
      isProcessing: true,
    );
    final aiIndex = state.messages.length; // 새로 추가될 index

    // 3) 스트리밍 호출
    _sub = ApiService.sendChatMessage(text).listen(
      (chunk) {
        aiMsg = aiMsg.copyWith(text: aiMsg.text + chunk);
        final msgs = List<ChatMessage>.from(state.messages);
        if (aiIndex >= msgs.length) {
          msgs.add(aiMsg);
        } else {
          msgs[aiIndex] = aiMsg;
        }
        state = state.copyWith(messages: msgs);
      },
      onDone: () => state = state.copyWith(isProcessing: false),
      onError: (e) {
        final err = ChatMessage(text: '⚠︎ $e', isUser: false);
        state = state.copyWith(
          messages: [...state.messages, err],
          isProcessing: false,
        );
      },
    );
  }
}

/// ─────────────────────────────────────────
/// PROVIDER (prompt 파라미터 전달)
/// ─────────────────────────────────────────
final chatViewModelProvider = StateNotifierProvider.autoDispose
    .family<ChatViewModel, ChatViewState, String>(
  (ref, prompt) => ChatViewModel(prompt),
);
