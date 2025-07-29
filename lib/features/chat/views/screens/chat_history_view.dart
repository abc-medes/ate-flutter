import 'package:flutter/cupertino.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/features/chat/view_models/chat_history_view_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ChatHistoryView extends ConsumerStatefulWidget {
  const ChatHistoryView({super.key});

  @override
  ConsumerState<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends ConsumerState<ChatHistoryView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ChatMessageDTO> _selectedDaySessions = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatHistoryViewModelProvider);
    final notifier = ref.read(chatHistoryViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        leading:
            CupertinoNavigationBarBackButton(onPressed: () => context.pop()),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : Column(
                  children: [
                    _buildCalendar(state.sessionsByDate),
                    const Divider(height: 1),
                    _buildSessionList(),
                  ],
                ),
    );
  }

  Widget _buildCalendar(Map<DateTime, List<ChatMessageDTO>> sessionsByDate) {
    return TableCalendar<ChatMessageDTO>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) =>
          sessionsByDate[DateTime.utc(
            day.year,
            day.month,
            day.day,
          )] ??
          [],
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedDaySessions = sessionsByDate[DateTime.utc(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                )] ??
                [];
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isNotEmpty) {
            return Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: $styles.colors.accent1,
                ),
                width: 16,
                height: 16,
                child: Center(
                  child: Text(
                    '${events.length}',
                    style: $styles.text.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: $styles.text.h3,
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: $styles.colors.accent1.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: $styles.colors.accent1,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    if (_selectedDaySessions.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            _selectedDay == null
                ? 'Select a day to see sessions'
                : 'No sessions on this day',
            style: $styles.text.body,
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: _selectedDaySessions.length,
        itemBuilder: (context, index) {
          final session = _selectedDaySessions[index];
          return ListTile(
            title: Text(
                'Chat from ${DateFormat.jm().format(session.createdAt.toLocal())}'),
            subtitle: Text(session.message,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              context.push(RouteNames.chat, extra: session.sessionId);
            },
          );
        },
      ),
    );
  }
}
