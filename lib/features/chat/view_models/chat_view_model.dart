import 'dart:async';
import 'dart:convert' as convert;

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/api_service.dart';
import 'package:bodido/core/services/chat_service.dart';
import 'package:bodido/core/services/tracking_questions_service.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:bodido/data/models/tracking_question_model.dart';

/// ─────────────────────────────────────────
/// STATE
/// ─────────────────────────────────────────
class ChatViewState {
  final List<ChatMessageDTO> currentSessionMessages;
  final Map<String, List<ChatMessageDTO>> messagesBySession;
  final bool isLoading;
  final String? error;
  final String? currentSessionId;
  final List<dynamic> timeline;
  final Map<String, List<TrackingQuestion>> questionsByTag;
  final Set<String> pendingQuestionTags; // NEW

  const ChatViewState({
    this.currentSessionMessages = const [],
    this.messagesBySession = const {},
    this.isLoading = false,
    this.error,
    this.currentSessionId,
    this.timeline = const [],
    this.questionsByTag = const {},
    this.pendingQuestionTags = const <String>{}, // NEW
  });

  ChatViewState copyWith({
    List<ChatMessageDTO>? currentSessionMessages,
    Map<String, List<ChatMessageDTO>>? messagesBySession,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? currentSessionId,
    List<dynamic>? timeline,
    Map<String, List<TrackingQuestion>>? questionsByTag,
    Set<String>? pendingQuestionTags,
  }) {
    return ChatViewState(
      currentSessionMessages:
          currentSessionMessages ?? this.currentSessionMessages,
      messagesBySession: messagesBySession ?? this.messagesBySession,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentSessionId: currentSessionId ?? this.currentSessionId,
      timeline: timeline ?? this.timeline,
      questionsByTag: questionsByTag ?? this.questionsByTag,
      pendingQuestionTags: pendingQuestionTags ?? this.pendingQuestionTags,
    );
  }
}

/// ─────────────────────────────────────────
/// VIEW-MODEL
/// ─────────────────────────────────────────
class ChatViewModel extends StateNotifier<ChatViewState> {
  final Ref ref;
  final Map<String, StreamSubscription<List<TrackingQuestion>>> _tagWatchers =
      {};

  static final _trackingEventRe = RegExp(
      r'\{[^{}]*"event"\s*:\s*"tracking_questions_(?:generating|ready)"[^{}]*\}');
  static final _trackingReadyRe =
      RegExp(r'\{[^{}]*"event"\s*:\s*"tracking_questions_ready"[^{}]*\}');
  static final _trackingGeneratingRe =
      RegExp(r'\{[^{}]*"event"\s*:\s*"tracking_questions_generating"[^{}]*\}');

  ChatViewModel(this.ref) : super(const ChatViewState());

  @override
  void dispose() {
    for (final s in _tagWatchers.values) {
      s.cancel();
    }
    _tagWatchers.clear();
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
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final chatService = ref.read(chatServiceProvider);
      final messages = await chatService.getChatHistory();

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

  Future<void> fetchQuestionsBySessionOnce(
    String sessionId, {
    int limit = 3,
    String? questionTag,
  }) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final pendingKey =
        questionTag == null ? sessionId : '${sessionId}::$questionTag';

    if (state.pendingQuestionTags.contains(pendingKey)) return;
    final nextPending = <String>{...state.pendingQuestionTags, pendingKey};
    state = state.copyWith(pendingQuestionTags: nextPending);

    try {
      final qs = await ref
          .read(trackingQuestionsServiceProvider)
          .listQuestionsByUserAndSession(
            userId: uid,
            sessionId: sessionId,
            limit: limit,
            questionTag: questionTag,
          );

      final questionsKey =
          questionTag == null ? sessionId : '${sessionId}::$questionTag';

      final questionsList = qs.take(limit).toList();

      final cleared = <String>{...state.pendingQuestionTags}
        ..remove(pendingKey);

      state = state.copyWith(
        questionsByTag: {
          ...state.questionsByTag,
          questionsKey: questionsList,
        },
        pendingQuestionTags: cleared,
      );
    } catch (e) {
      debugPrint('[ChatVM] fetchQuestionsBySessionOnce error: $e');
      final cleared = <String>{...state.pendingQuestionTags}
        ..remove(pendingKey);
      state = state.copyWith(pendingQuestionTags: cleared);
    }
  }

  Future<void> sendMessage(ChatMessageDTO message,
      {String? watchTagOnDone}) async {
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
        if (!mounted) return;
        final chunkText = chunkMessage.message ?? '';
        final sanitizedChunk = chunkText.replaceAll(_trackingEventRe, '');
        final currentMessages = state.currentSessionMessages;
        if (currentMessages.isNotEmpty && !currentMessages.last.isUser) {
          final updatedAI = currentMessages.last.copyWith(
            message: (currentMessages.last.message ?? '') + sanitizedChunk,
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

        if (_trackingGeneratingRe.hasMatch(chunkText)) {
          final match = _trackingGeneratingRe.allMatches(chunkText).last;
          final obj = convert.jsonDecode(match.group(0)!);
          final tag = obj['tag']?.toString();
          final pendingKey =
              tag == null ? message.sessionId : '${message.sessionId}::$tag';
          final nextPending = <String>{
            ...state.pendingQuestionTags,
            pendingKey
          };
          state = state.copyWith(pendingQuestionTags: nextPending);
        }

        if (_trackingReadyRe.hasMatch(chunkText)) {
          try {
            final match = _trackingReadyRe.allMatches(chunkText).last;
            final obj = convert.jsonDecode(match.group(0)!);
            final tag = obj['tag']?.toString();
            final count = obj['count']?.toString();
            debugPrint(
                '[ChatVM] tracking_questions_ready: tag=$tag count=$count');

            fetchQuestionsBySessionOnce(
              message.sessionId,
              limit: 3,
              questionTag: tag,
            );
          } catch (e) {
            debugPrint(
                '[ChatVM] failed to parse tracking_questions_ready event: $e');
          }
        }
      },
      onDone: () async {
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

  DateTime _msgTs(ChatMessageDTO m) => m.clientLocalTimestamp ?? m.createdAt;

  DateTime _snapTs(BodySimulatorStateSnapshotDTO s) => s.createdAt;

  void initializeFromEvents({
    required List<dynamic> events,
    String? selectedSessionId,
  }) {
    final msgs = events.whereType<ChatMessageDTO>().toList();
    final snaps = events.whereType<BodySimulatorStateSnapshotDTO>().toList();

    final timeline = <dynamic>[...msgs, ...snaps]..sort((a, b) {
        final ta = a is ChatMessageDTO
            ? _msgTs(a)
            : _snapTs(a as BodySimulatorStateSnapshotDTO);
        final tb = b is ChatMessageDTO
            ? _msgTs(b)
            : _snapTs(b as BodySimulatorStateSnapshotDTO);
        return ta.compareTo(tb);
      });

    final sessionId =
        selectedSessionId ?? (msgs.isNotEmpty ? msgs.first.sessionId : null);
    final sessionMsgs = sessionId == null
        ? const <ChatMessageDTO>[]
        : msgs.where((m) => m.sessionId == sessionId).toList();

    state = state.copyWith(
      currentSessionId: sessionId,
      currentSessionMessages: sessionMsgs,
      messagesBySession: sessionId == null ? {} : {sessionId: sessionMsgs},
      isLoading: false,
      timeline: timeline,
    );
  }

  Future<void> answerTrackingQuestion({
    required String sessionId,
    required TrackingQuestion question,
    required QuestionOption option,
  }) async {
    final req = UserSelectionRequest(
      questionId: question.id,
      questionTag: question.questionTag,
      optionId: option.id,
      selectionKey: option.selectionKey,
      sessionId: sessionId,
      clientLocalTimestamp: DateTime.now(),
    );

    try {
      await ApiService.selectTrackingOption(request: req, dryRun: false);
      removeQuestionFromSession(
        sessionId: sessionId,
        questionId: question.id,
        questionTag: question.questionTag,
      );
    } catch (e) {
      debugPrint('[ChatVM] Failed to upsert tracking question: $e');
      rethrow;
    }
  }

  void removeQuestionFromSession({
    required String sessionId,
    required String questionId,
    String? questionTag,
  }) {
    final key = (questionTag == null || questionTag.isEmpty)
        ? sessionId
        : '${sessionId}::$questionTag';

    final existing = state.questionsByTag[key];
    if (existing == null) return;

    final updatedList = existing.where((q) => q.id != questionId).toList();
    final updatedMap = {...state.questionsByTag};

    if (updatedList.isEmpty) {
      updatedMap.remove(key);
    } else {
      updatedMap[key] = updatedList;
    }

    final cleanedPending = state.pendingQuestionTags
        .where((pendingKey) => pendingKey != key && pendingKey != sessionId)
        .toSet();

    state = state.copyWith(
      questionsByTag: updatedMap,
      pendingQuestionTags: cleanedPending,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// ─────────────────────────────────────────
/// PROVIDER (prompt 파라미터 전달)
/// ─────────────────────────────────────────
final chatViewModelProvider =
    StateNotifierProvider.autoDispose<ChatViewModel, ChatViewState>(
  (ref) => ChatViewModel(ref),
);
