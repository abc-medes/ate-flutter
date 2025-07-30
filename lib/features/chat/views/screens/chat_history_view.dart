import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/core/widgets/chat_input.dart';
import 'package:regene/core/widgets/circular_icon_button.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/features/chat/view_models/chat_history_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class ChatHistoryView extends ConsumerStatefulWidget {
  const ChatHistoryView({super.key});

  @override
  ConsumerState<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends ConsumerState<ChatHistoryView> {
  late final PageController _pageController;
  final int _initialPage = 1200; // For "infinite" vertical scrolling

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatHistoryViewModelProvider.notifier)
          .onMonthChanged(_focusedDay);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _pageToMonth(int page) {
    final monthOffset = page - _initialPage;
    final now = DateTime.now();
    return DateTime(now.year, now.month + monthOffset, 1);
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final state = ref.read(chatHistoryViewModelProvider);
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    return state.eventsByDate[dayUtc] ?? [];
  }

  int _getWeeksInMonth(DateTime month) {
    final firstDay = DateTime.utc(month.year, month.month, 1);
    final lastDay = DateTime.utc(month.year, month.month + 1, 0);
    final firstWeekday =
        firstDay.weekday == 7 ? 0 : firstDay.weekday; // Adjust for Monday start
    final totalDays = firstWeekday + lastDay.day;
    return (totalDays / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(chatHistoryViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          _buildHeader(context, _focusedDay, ref),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pageViewHeight = constraints.maxHeight;

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (page) {
                    final newFocusedDay = _pageToMonth(page);
                    setState(() {
                      _focusedDay = newFocusedDay;
                      _selectedDay = null; // Clear selection when month changes
                    });
                    viewModel.onMonthChanged(newFocusedDay);
                  },
                  itemBuilder: (context, index) {
                    final month = _pageToMonth(index);
                    final weeks = _getWeeksInMonth(month);
                    const daysOfWeekHeight = 24.0;
                    final rowHeight =
                        (pageViewHeight - 150 - daysOfWeekHeight) / weeks;

                    return TableCalendar<dynamic>(
                      focusedDay: month,
                      // These need to be wide enough to not crash.
                      firstDay: DateTime.utc(month.year, month.month, 1),
                      lastDay: DateTime.utc(month.year, month.month + 1, 0),
                      rowHeight: rowHeight,
                      daysOfWeekHeight: daysOfWeekHeight,
                      headerVisible: false,
                      availableGestures:
                          AvailableGestures.none, // Scrolling is by PageView
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: _getEventsForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            // focusedDay is managed by the PageView
                          });
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          ChatInput(
            onSubmit: (ChatMessage chatMessage) {
              if (chatMessage.message.isNotEmpty) {
                context.go(RouteNames.chat, extra: {
                  'message': chatMessage.message,
                  'chatOffset': chatMessage.chatOffset,
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, DateTime focusedMonth, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB($styles.insets.md, mq.padding.top,
          $styles.insets.md, $styles.insets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularIconButton(
              icon: Icons.arrow_back,
              size: 48,
              iconColor: $styles.colors.black,
              backgroundColor: Colors.transparent,
              onTap: () => context.pop()),
          Text(
            DateFormat.yMMMM().format(focusedMonth),
            style: $styles.text.h3,
          ),
          const SizedBox(width: 48), // To balance the back button
        ],
      ),
    );
  }
}
