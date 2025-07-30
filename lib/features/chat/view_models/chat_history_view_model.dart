import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/data/models/body_simulator_model.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:intl/intl.dart';

// BodySimulatorStateSnapshotDTO가 이 파일에 없으므로 임시로 정의합니다.
// 실제로는 body_simulator_model.dart에서 import 해야 합니다.

@immutable
class ChatHistoryState {
  // 불러온 모든 월의 이벤트를 누적하여 저장합니다.
  final Map<DateTime, List<dynamic>> eventsByDate;
  final Map<String, bool> monthlyLoadingStatus; // Key: "YYYY-MM"
  final DateTime focusedMonth;
  final String? error;

  ChatHistoryState({
    this.eventsByDate = const {},
    this.monthlyLoadingStatus = const {},
    DateTime? focusedMonth,
    this.error,
  }) : focusedMonth = focusedMonth ?? DateTime.now();

  ChatHistoryState copyWith({
    Map<DateTime, List<dynamic>>? eventsByDate,
    Map<String, bool>? monthlyLoadingStatus,
    DateTime? focusedMonth,
    String? error,
  }) {
    return ChatHistoryState(
      eventsByDate: eventsByDate ?? this.eventsByDate,
      monthlyLoadingStatus: monthlyLoadingStatus ?? this.monthlyLoadingStatus,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      error: error ?? this.error,
    );
  }
}

class ChatHistoryViewModel extends StateNotifier<ChatHistoryState> {
  ChatHistoryViewModel(this._ref) : super(ChatHistoryState());

  final Ref _ref;
  final Set<String> _loadedMonths = {};

  Future<void> onMonthChanged(DateTime month) async {
    final monthKey = DateFormat('yyyy-MM').format(month);
    if (_loadedMonths.contains(monthKey)) {
      state = state.copyWith(focusedMonth: month);
      return;
    }

    if (!mounted) return;
    // Set loading status for this specific month
    state = state.copyWith(
      focusedMonth: month,
      monthlyLoadingStatus: {...state.monthlyLoadingStatus, monthKey: true},
    );

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in.');

      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final results = await Future.wait([
        _fetchChatMessagesForMonth(userId, firstDay, lastDay),
        _fetchBodySnapshotsForMonth(userId, firstDay, lastDay),
      ]);

      if (!mounted) return;

      final monthlyMessages = results[0] as List<ChatMessageDTO>;
      final monthlySnapshots =
          results[1] as List<BodySimulatorStateSnapshotDTO>;

      final newEvents = _groupEventsByDate(monthlyMessages, monthlySnapshots);
      final updatedEvents =
          Map<DateTime, List<dynamic>>.from(state.eventsByDate)
            ..addAll(newEvents);

      _loadedMonths.add(monthKey);
      state = state.copyWith(
        eventsByDate: updatedEvents,
        monthlyLoadingStatus: {...state.monthlyLoadingStatus, monthKey: false},
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        error: e.toString(),
        monthlyLoadingStatus: {...state.monthlyLoadingStatus, monthKey: false},
      );
    }
  }

  Future<List<ChatMessageDTO>> _fetchChatMessagesForMonth(
      String userId, DateTime firstDay, DateTime lastDay) async {
    final response = await Supabase.instance.client
        .from('chat_history')
        .select()
        .eq('user_id', userId)
        .gte('created_at', firstDay.toIso8601String())
        .lte('created_at', lastDay.toIso8601String());

    return (response as List)
        .map((item) => ChatMessageDTO.fromJson(item))
        .toList();
  }

  Future<List<BodySimulatorStateSnapshotDTO>> _fetchBodySnapshotsForMonth(
      String userId, DateTime firstDay, DateTime lastDay) async {
    final response = await Supabase.instance.client
        .from('body_simulator_state_snapshots')
        .select()
        .eq('user_id', userId)
        .gte('created_at', firstDay.toIso8601String())
        .lte('created_at', lastDay.toIso8601String());

    return (response as List)
        .map((item) => BodySimulatorStateSnapshotDTO.fromJson(item))
        .toList();
  }

  Map<DateTime, List<dynamic>> _groupEventsByDate(List<ChatMessageDTO> messages,
      List<BodySimulatorStateSnapshotDTO> snapshots) {
    final eventsByDate = <DateTime, List<dynamic>>{};

    final sessionsById = groupBy(messages, (dto) => dto.sessionId);
    sessionsById.forEach((sessionId, messages) {
      if (messages.isNotEmpty) {
        final firstMessage = messages.first;
        final date = DateTime.utc(firstMessage.createdAt.year,
            firstMessage.createdAt.month, firstMessage.createdAt.day);
        eventsByDate.putIfAbsent(date, () => []).add(firstMessage);
      }
    });

    for (var snapshot in snapshots) {
      final date = DateTime.utc(snapshot.createdAt.year,
          snapshot.createdAt.month, snapshot.createdAt.day);
      eventsByDate.putIfAbsent(date, () => []).add(snapshot);
    }

    return eventsByDate;
  }
}

final chatHistoryViewModelProvider =
    StateNotifierProvider.autoDispose<ChatHistoryViewModel, ChatHistoryState>(
  (ref) => ChatHistoryViewModel(ref),
);
