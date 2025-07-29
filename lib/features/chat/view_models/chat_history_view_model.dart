import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/services/chat_service.dart';
import 'package:regene/data/models/chat_model.dart';

/// ─────────────────────────────────────────
/// STATE
/// ─────────────────────────────────────────
@immutable
class ChatHistoryState {
  final Map<DateTime, List<ChatMessageDTO>> sessionsByDate;

  final Map<String, List<ChatMessageDTO>> sessionsById;

  final List<String> orderedSessionIds;

  final bool isLoading;
  final String? error;

  const ChatHistoryState({
    this.sessionsByDate = const {},
    this.sessionsById = const {},
    this.orderedSessionIds = const [],
    this.isLoading = true,
    this.error,
  });

  ChatHistoryState copyWith({
    Map<DateTime, List<ChatMessageDTO>>? sessionsByDate,
    Map<String, List<ChatMessageDTO>>? sessionsById,
    List<String>? orderedSessionIds,
    bool? isLoading,
    String? error,
  }) {
    return ChatHistoryState(
      sessionsByDate: sessionsByDate ?? this.sessionsByDate,
      sessionsById: sessionsById ?? this.sessionsById,
      orderedSessionIds: orderedSessionIds ?? this.orderedSessionIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// ─────────────────────────────────────────
/// VIEW-MODEL
/// ─────────────────────────────────────────
class ChatHistoryViewModel extends StateNotifier<ChatHistoryState> {
  ChatHistoryViewModel(this._ref) : super(const ChatHistoryState()) {
    _fetchHistory();
  }

  final Ref _ref;

  Future<void> _fetchHistory() async {
    try {
      state = state.copyWith(isLoading: true);
      final allMessageDTOs =
          await _ref.read(chatServiceProvider).getChatHistory();

      // Group messages by their session ID first
      final sessionsById = groupBy(allMessageDTOs, (dto) => dto.sessionId);

      // Group the first message of each session by its creation date
      final sessionsByDate = <DateTime, List<ChatMessageDTO>>{};
      sessionsById.forEach((sessionId, messages) {
        if (messages.isNotEmpty) {
          final firstMessage = messages.first;
          final date = DateTime.utc(firstMessage.createdAt.year,
              firstMessage.createdAt.month, firstMessage.createdAt.day);
          if (sessionsByDate[date] == null) {
            sessionsByDate[date] = [];
          }
          // We only need one representative message (or just the session ID)
          // to mark the calendar. Let's add the first message.
          sessionsByDate[date]!.add(firstMessage);
        }
      });

      // Create a sorted list of session IDs for stable ordering
      final orderedSessionIds = sessionsById.keys.toList()
        ..sort((a, b) {
          final dateA = sessionsById[a]!.first.createdAt;
          final dateB = sessionsById[b]!.first.createdAt;
          return dateA.compareTo(dateB); // Oldest first
        });

      state = state.copyWith(
        sessionsByDate: sessionsByDate,
        sessionsById: sessionsById,
        orderedSessionIds: orderedSessionIds,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

/// ─────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────
final chatHistoryViewModelProvider =
    StateNotifierProvider<ChatHistoryViewModel, ChatHistoryState>(
  (ref) => ChatHistoryViewModel(ref),
);
