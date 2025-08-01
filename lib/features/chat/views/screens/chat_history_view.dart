import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/core/widgets/chat_input.dart';
import 'package:regene/core/widgets/circular_icon_button.dart';
import 'package:regene/core/widgets/error_snackbar.dart';
import 'package:regene/data/models/body_simulator_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(chatHistoryViewModelProvider.notifier);
    final state = ref.watch(chatHistoryViewModelProvider);

    ref.listen<ChatHistoryState>(chatHistoryViewModelProvider, (_, next) {
      if (next.error != null) {
        ErrorSnackbar.showChatHistoryError(
          context: context,
          errorMessage: next.error!,
          clearError: viewModel.clearError,
          onTryAgain: () => viewModel.onMonthChanged(state.focusedMonth),
        );
      }
    });

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          _buildHeader(context, _focusedDay, ref),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: $styles.insets.sm),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pageViewHeight = constraints.maxHeight;
                  const double weeksInMonth =
                      6.0; // Always calculate height for 6 weeks
                  final daysOfWeekHeight = $styles.insets.md;
                  final rowHeight =
                      (pageViewHeight - daysOfWeekHeight) / weeksInMonth;

                  return PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (page) {
                      final newFocusedDay = _pageToMonth(page);
                      setState(() {
                        _focusedDay = newFocusedDay;
                        _selectedDay =
                            null; // Clear selection when month changes
                      });
                      viewModel.onMonthChanged(newFocusedDay);
                    },
                    itemBuilder: (context, index) {
                      final month = _pageToMonth(index);
                      return TableCalendar<dynamic>(
                        focusedDay: month,
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
                            });
                          }
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) {
                            // Return an empty container to hide default markers
                            return Container();
                          },
                          defaultBuilder: (context, day, focusedDay) {
                            return _buildCellContent(day);
                          },
                          todayBuilder: (context, day, focusedDay) {
                            return _buildCellContent(day, isToday: true);
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            return _buildCellContent(day, isSelected: true);
                          },
                          outsideBuilder: (context, day, focusedDay) {
                            return _buildCellContent(day, isOutside: true);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
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

  Widget _buildCellContent(DateTime day,
      {bool isToday = false, bool isSelected = false, bool isOutside = false}) {
    final events = _getEventsForDay(day);
    final chatCount = events.whereType<ChatMessageDTO>().length;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all($styles.insets.xxs),
      decoration: BoxDecoration(
        color: isSelected ? $styles.colors.accent1.withOpacity(0.2) : null,
        borderRadius: BorderRadius.circular($styles.corners.sm),
        border: isToday
            ? Border.all(color: $styles.colors.accent1, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${day.day}',
                style: $styles.text.bodySmall.copyWith(
                  color:
                      isOutside ? $styles.colors.caption : $styles.colors.black,
                ),
              ),
              if (chatCount > 0 && !isOutside) ...[
                SizedBox(width: $styles.insets.xxs),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: $styles.insets.xxs,
                      vertical: $styles.insets.xxs / 2),
                  decoration: BoxDecoration(
                    color: $styles.colors.accent1,
                    borderRadius: BorderRadius.circular($styles.corners.sm),
                  ),
                  child: Text(
                    '$chatCount',
                    style: $styles.text.caption.copyWith(
                        color: $styles.colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          if (events.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  String title = 'Unknown event';
                  IconData icon = Icons.event;
                  Color iconColor = $styles.colors.caption;

                  if (event is ChatMessageDTO) {
                    title = event.message;
                    icon = Icons.chat_bubble_outline;
                    iconColor = $styles.colors.accent1;
                  } else if (event is BodySimulatorStateSnapshotDTO) {
                    title =
                        'Body Score: ${event.healthScore.overallScore.toStringAsFixed(1)}';
                    icon = Icons.monitor_heart_outlined;
                    iconColor = $styles.colors.accent2;
                  }

                  return Row(
                    children: [
                      Icon(icon, size: 12, color: iconColor),
                      SizedBox(width: $styles.insets.xxs),
                      Expanded(
                        child: Text(
                          title,
                          style: $styles.text.caption.copyWith(
                            color: isOutside
                                ? $styles.colors.caption
                                : $styles.colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  );
                },
              ),
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
          SizedBox(
              width: $styles
                  .insets.xl), // To balance the back button with a sized box
        ],
      ),
    );
  }
}
