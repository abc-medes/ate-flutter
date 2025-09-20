import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:bodido/core/services/chat_service.dart';

final chatViewModelProvider =
    StateNotifierProvider.autoDispose<ChatViewModel, ChatViewState>(
  (ref) => ChatViewModel(ref),
);

/// ─────────────────────────────────────────
/// STATE
/// ─────────────────────────────────────────
class ChatViewState {
  final List<ChatMessageDTO> currentSessionMessages;
  final Map<String, List<ChatMessageDTO>> messagesBySession;
  final bool isLoading;
  final String? error;
  final String? currentSessionId;

  const ChatViewState({
    this.currentSessionMessages = const [],
    this.messagesBySession = const {},
    this.isLoading = false,
    this.error,
    this.currentSessionId,
  });

  ChatViewState copyWith({
    List<ChatMessageDTO>? currentSessionMessages,
    Map<String, List<ChatMessageDTO>>? messagesBySession,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? currentSessionId,
  }) {
    return ChatViewState(
      currentSessionMessages:
          currentSessionMessages ?? this.currentSessionMessages,
      messagesBySession: messagesBySession ?? this.messagesBySession,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }
}

/// ─────────────────────────────────────────
/// VIEW-MODEL
/// ─────────────────────────────────────────
class ChatViewModel extends StateNotifier<ChatViewState> {
  final Ref ref;
  StreamSubscription<String>? _sub;

  ChatViewModel(this.ref) : super(const ChatViewState());

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> initializeChat({
    String? selectedSessionId,
    ChatMessageDTO? initialMessage,
  }) async {
    // Reset state
    state = const ChatViewState();

    if (selectedSessionId != null) {
      await loadMessagesForSession(selectedSessionId);
    }

    // If there's an initial message, send it automatically
    if (initialMessage != null) {
      await sendMessage(initialMessage);
    }
  }

  Future<void> loadMessagesForSession(String sessionId) async {
    if (state.messagesBySession.containsKey(sessionId)) {
      state = state.copyWith(
        currentSessionMessages: state.messagesBySession[sessionId]!,
        currentSessionId: sessionId,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final chatService = ref.read(chatServiceProvider);
      final messages = await chatService.getChatHistory();

      // Filter messages for this session
      final sessionMessages =
          messages.where((msg) => msg.sessionId == sessionId).toList();

      state = state.copyWith(
        currentSessionMessages: sessionMessages,
        messagesBySession: {
          ...state.messagesBySession,
          sessionId: sessionMessages,
        },
        currentSessionId: sessionId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> sendMessage(ChatMessageDTO message) async {
    if (message.message?.trim().isEmpty == true) return;

    // Add user message immediately
    final updatedMessages = [...state.currentSessionMessages, message];
    state = state.copyWith(
      currentSessionMessages: updatedMessages,
      messagesBySession: {
        ...state.messagesBySession,
        message.sessionId: updatedMessages,
      },
    );

    // Create AI message placeholder
    final aiMessage = ChatMessageDTO(
      userId: message.userId,
      sessionId: message.sessionId,
      message: '',
      isUser: false,
      createdAt: DateTime.now(),
      clientLocalTimestamp: DateTime.now(),
      chatOffset: message.chatOffset,
    );

    // Add AI message placeholder
    final messagesWithAI = [...updatedMessages, aiMessage];
    state = state.copyWith(
      currentSessionMessages: messagesWithAI,
      messagesBySession: {
        ...state.messagesBySession,
        message.sessionId: messagesWithAI,
      },
      isLoading: true,
    );

    // Start streaming using ChatService
    final chatService = ref.read(chatServiceProvider);
    chatService.sendPrompt(
      message,
      onChunk: (ChatMessageDTO chunkMessage) {
        // Update the AI message with the chunk
        final currentMessages = state.currentSessionMessages;
        if (currentMessages.isNotEmpty && !currentMessages.last.isUser) {
          final updatedAI = currentMessages.last.copyWith(
            message: (currentMessages.last.message ?? '') +
                (chunkMessage.message ?? ''),
          );
          final updatedMessages = [...currentMessages];
          updatedMessages[updatedMessages.length - 1] = updatedAI;

          state = state.copyWith(
            currentSessionMessages: updatedMessages,
            messagesBySession: {
              ...state.messagesBySession,
              message.sessionId: updatedMessages,
            },
          );
        }
      },
      onDone: () {
        state = state.copyWith(isLoading: false);
      },
      onError: (String error) {
        state = state.copyWith(
          error: error,
          isLoading: false,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// ─────────────────────────────────────────
/// PROVIDER (prompt 파라미터 전달)
/// ─────────────────────────────────────────
