import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

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
    bool clearError = false,
  }) {
    return ChatHistoryState(
      eventsByDate: eventsByDate ?? this.eventsByDate,
      monthlyLoadingStatus: monthlyLoadingStatus ?? this.monthlyLoadingStatus,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ChatHistoryViewModel extends StateNotifier<ChatHistoryState> {
  ChatHistoryViewModel(this._ref) : super(ChatHistoryState());

  final Ref _ref;
  final Set<String> _loadedMonths = {};

  void clearError() {
    if (mounted) {
      state = state.copyWith(clearError: true);
    }
  }

  void refreshCurrentMonth() {
    final monthKey = DateFormat('yyyy-MM').format(state.focusedMonth);
    _loadedMonths.remove(monthKey);
    onMonthChanged(state.focusedMonth);
  }

  Future<void> onMonthChanged(DateTime month) async {
    final monthKey = DateFormat('yyyy-MM').format(month);
    if (_loadedMonths.contains(monthKey)) {
      state = state.copyWith(focusedMonth: month);
      return;
    }

    if (!mounted) return;
    state = state.copyWith(
      focusedMonth: month,
      monthlyLoadingStatus: {...state.monthlyLoadingStatus, monthKey: true},
      clearError: true,
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
      debugPrint(
          '[ChatHistoryViewModel] Grouped Events for $monthKey: $newEvents');

      final updatedEvents =
          Map<DateTime, List<dynamic>>.from(state.eventsByDate)
            ..addAll(newEvents);

      _loadedMonths.add(monthKey);
      state = state.copyWith(
        eventsByDate: updatedEvents,
        monthlyLoadingStatus: {...state.monthlyLoadingStatus, monthKey: false},
      );
    } catch (e, st) {
      debugPrint('[ChatHistoryViewModel] Error onMonthChanged: $e\n$st');
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
        .select(
            'session_id, message, chat_offset, client_local_timestamp_iso, created_at, is_user')
        .eq('user_id', userId)
        .gte('client_local_timestamp_iso', firstDay.toIso8601String())
        .lte('client_local_timestamp_iso', lastDay.toIso8601String());

    final messages = (response as List)
        .map((item) => ChatMessageDTO.fromJson({
              ...item,
              'user_id': userId,
            }))
        .toList();
    debugPrint(
        '[ChatHistoryViewModel] Fetched ${messages.length} chat messages for ${DateFormat('yyyy-MM').format(firstDay)}');
    return messages;
  }

  Future<List<BodySimulatorStateSnapshotDTO>> _fetchBodySnapshotsForMonth(
      String userId, DateTime firstDay, DateTime lastDay) async {
    final response = await Supabase.instance.client
        .from('user_body_state_snapshots')
        .select()
        .eq('user_id', userId)
        .gte('created_at', firstDay.toIso8601String())
        .lte('created_at', lastDay.toIso8601String());

    final snapshots = (response as List)
        .map((item) => BodySimulatorStateSnapshotDTO.fromJson(item))
        .toList();
    debugPrint(
        '[ChatHistoryViewModel] Fetched ${snapshots.length} body snapshots for ${DateFormat('yyyy-MM').format(firstDay)}');
    return snapshots;
  }

  Map<DateTime, List<dynamic>> _groupEventsByDate(
    List<ChatMessageDTO> messages,
    List<BodySimulatorStateSnapshotDTO> snapshots,
  ) {
    final Map<DateTime, List<dynamic>> eventsByDate = {};

    final messagesByDate = groupBy<ChatMessageDTO, DateTime>(
      messages,
      (message) {
        final localTime = message.clientLocalTimestamp ?? message.createdAt;
        return DateTime.utc(localTime.year, localTime.month, localTime.day);
      },
    );

    messagesByDate.forEach((date, dailyMessages) {
      final uniqueSessions =
          dailyMessages.map((m) => m.sessionId).toSet().toList();
      eventsByDate.putIfAbsent(date, () => []);
      for (var sessionId in uniqueSessions) {
        final representativeMessage =
            dailyMessages.firstWhere((m) => m.sessionId == sessionId);
        eventsByDate[date]!.add(representativeMessage);
      }
    });

    final snapshotsByDate = groupBy<BodySimulatorStateSnapshotDTO, DateTime>(
      snapshots,
      (snapshot) => DateTime.utc(snapshot.createdAt.year,
          snapshot.createdAt.month, snapshot.createdAt.day),
    );

    snapshotsByDate.forEach((date, dailySnapshots) {
      eventsByDate.putIfAbsent(date, () => []).addAll(dailySnapshots);
    });

    return eventsByDate;
  }
}

final chatHistoryViewModelProvider =
    StateNotifierProvider.autoDispose<ChatHistoryViewModel, ChatHistoryState>(
  (ref) => ChatHistoryViewModel(ref),
);
