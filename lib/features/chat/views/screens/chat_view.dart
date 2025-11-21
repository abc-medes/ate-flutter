import 'dart:async';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/services/user_service.dart';
import 'package:bodido/core/widgets/chat_input.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:bodido/data/models/tracking_question_model.dart';
import 'package:bodido/features/chat/view_models/chat_history_view_model.dart';
import 'package:bodido/features/chat/view_models/chat_view_model.dart';
import 'package:bodido/features/home/views/widgets/tracking_questions_section.dart';
import 'package:intl/intl.dart';

class ChatView extends ConsumerStatefulWidget {
  final ChatMessageDTO? initialMessage;
  final List<String>? sessionIds; // Add this for multiple sessions
  final DateTime? selectedDate; // Add this for the selected date

  const ChatView({
    super.key,
    this.initialMessage,
    this.sessionIds,
    this.selectedDate,
  });

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  final ScrollController _scrollController = ScrollController();
  Timer? _scrollDebounce;

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          pos,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(pos);
      }
    });
  }

  void _scrollToBottomDebounced() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 50), _scrollToBottom);
  }

  @override
  void initState() {
    super.initState();

    if (widget.sessionIds != null && widget.sessionIds!.isNotEmpty) {
      _currentPageIndex = 0;
    }

    _pageController = PageController(initialPage: _currentPageIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = ref.read(chatHistoryViewModelProvider);
      final date = widget.selectedDate ?? DateTime.now();
      final dayUtc = DateTime.utc(date.year, date.month, date.day);
      final events = history.eventsByDate[dayUtc] ?? [];

      final sessionsFromEvents = events
          .whereType<ChatMessageDTO>()
          .map((e) => e.sessionId)
          .toSet()
          .toList();

      final selectedId = (widget.sessionIds?.isNotEmpty ?? false)
          ? widget.sessionIds!.first
          : (sessionsFromEvents.isNotEmpty ? sessionsFromEvents.first : null);

      final vm = ref.read(chatViewModelProvider.notifier);

      // Hydrate when there are existing events
      if (events.isNotEmpty) {
        vm.initializeFromEvents(
          events: events,
          selectedSessionId: selectedId,
        );
      }

      // Always ensure currentSessionId is set and initialMessage is sent
      vm.initializeChat(
        selectedSessionId: selectedId,
        initialMessage: widget.initialMessage,
      );
    });
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(chatViewModelProvider);
    final viewModelNotifier = ref.read(chatViewModelProvider.notifier);

    ref.listen<ChatViewState>(chatViewModelProvider, (prev, next) {
      if (!mounted) return;

      final active = next.currentSessionId;
      final isActivePage = active != null &&
          widget.sessionIds != null &&
          widget.sessionIds!.isNotEmpty &&
          widget.sessionIds![_currentPageIndex] == active;

      if (!isActivePage) return;

      final prevLen = prev?.currentSessionMessages.length ?? 0;
      final nextLen = next.currentSessionMessages.length;

      final appendedMessage = nextLen > prevLen;
      final streamingUpdated = nextLen > 0 &&
          prevLen > 0 &&
          next.currentSessionMessages.last.message !=
              prev!.currentSessionMessages.last.message;

      if (appendedMessage || streamingUpdated) {
        _scrollToBottomDebounced();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, DateTime.now(), ref),
          Expanded(
            child:
                viewModel.isLoading && viewModel.currentSessionMessages.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : viewModel.error != null
                        ? Center(child: Text('Error: ${viewModel.error}'))
                        : _buildDynamicScrollView(viewModel),
          ),
          ChatInput(
            onSubmit: (ChatMessageDTO message) {
              viewModelNotifier.sendMessage(
                message,
                watchTagOnDone: message.sessionId,
              );
            },
            isProcessing: viewModel.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicScrollView(ChatViewState viewModel) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            padEnds: false,
            controller: _pageController,
            itemCount: widget.sessionIds!.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
              final sessionId = widget.sessionIds![index];
              ref
                  .read(chatViewModelProvider.notifier)
                  .loadMessagesForSession(sessionId);
            },
            itemBuilder: (context, index) {
              final sessionId = widget.sessionIds![index];
              final isCurrentSession = sessionId == viewModel.currentSessionId;

              if (isCurrentSession) {
                if (viewModel.currentSessionMessages.isEmpty) {
                  return Center(
                    child: Text(
                      $strings.chat_no_messages,
                      style: $styles.text.body.copyWith(
                        color: $styles.colors.caption,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Session indicator at top of scroll view
                      if (widget.sessionIds != null &&
                          widget.sessionIds!.length > 1)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: $styles.insets.md,
                            vertical: $styles.insets.sm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                $strings.chat_session_indicator(
                                    _currentPageIndex + 1,
                                    widget.sessionIds!.length),
                                style: $styles.text.caption.copyWith(
                                  color: $styles.colors.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...List.generate(
                        viewModel.currentSessionMessages.length,
                        (messageIndex) {
                          final message =
                              viewModel.currentSessionMessages[messageIndex];
                          return _buildMessageItem(message, messageIndex);
                        },
                      ),
                      // Guide text for horizontal scrolling
                      if (widget.sessionIds!.length > 1)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: $styles.insets.md,
                            vertical: $styles.insets.sm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.swipe_left,
                                size: 16,
                                color: $styles.colors.caption,
                              ),
                              SizedBox(width: $styles.insets.xs),
                              Text(
                                $strings.chat_swipe_hint,
                                style: $styles.text.caption.copyWith(
                                  color: $styles.colors.caption,
                                ),
                              ),
                              SizedBox(width: $styles.insets.xs),
                              Icon(
                                Icons.swipe_right,
                                size: 16,
                                color: $styles.colors.caption,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              } else {
                // Show loading for other sessions
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: $styles.insets.md),
                      Text(
                        $strings.chat_loading_session(index + 1),
                        style: $styles.text.body.copyWith(
                          color: $styles.colors.caption,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessageDTO message, int index) {
    final content = message.message ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.lg,
        vertical: $styles.insets.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: $styles.insets.lg,
                vertical: $styles.insets.md,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? $styles.colors.accent1
                    : $styles.colors.accent2,
                borderRadius: BorderRadius.circular($styles.corners.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser &&
                      (message.message == null ||
                          message.message!.isEmpty)) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: $styles.insets.xs),
                        Text(
                          $strings.chat_generating,
                          style: $styles.text.caption.copyWith(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      content,
                      style: $styles.text.body.copyWith(
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    Builder(
                      builder: (_) {
                        if (message.isUser) return const SizedBox.shrink();

                        final vm = ref.watch(chatViewModelProvider);
                        final isLastMessage =
                            index == (vm.currentSessionMessages.length - 1);
                        if (!isLastMessage) return const SizedBox.shrink();

                        final sid = message.sessionId;

                        List<TrackingQuestion> qs = const [];
                        bool isPending = false;

                        for (final pendingKey in vm.pendingQuestionTags) {
                          if (pendingKey == sid ||
                              pendingKey.startsWith('$sid::')) {
                            isPending = true;
                            break;
                          }
                        }

                        qs = vm.questionsByTag[sid] ?? const [];
                        if (qs.isEmpty) {
                          for (final key in vm.questionsByTag.keys) {
                            if (key == sid || key.startsWith('$sid::')) {
                              final foundQs = vm.questionsByTag[key];
                              if (foundQs != null && foundQs.isNotEmpty) {
                                qs = foundQs;
                                break;
                              }
                            }
                          }
                        }

                        if (qs.isNotEmpty) {
                          return Padding(
                              padding: EdgeInsets.only(top: $styles.insets.sm),
                              child: TrackingQuestionsSection(
                                isLoading: false,
                                questions: qs,
                                selectedOptions: const {},
                                isChat: true,
                                onOptionSelected: (q, opt) async {
                                  final uid =
                                      ref.read(userServiceProvider).userId;
                                  await ref
                                      .read(chatViewModelProvider.notifier)
                                      .answerTrackingQuestion(
                                        sessionId: sid,
                                        question: q,
                                        option: opt,
                                      );
                                  await ref
                                      .read(chatViewModelProvider.notifier)
                                      .sendMessage(
                                        ChatMessageDTO(
                                          userId: uid,
                                          sessionId: sid,
                                          message:
                                              '${q.question} - ${opt.label}',
                                          isUser: true,
                                          createdAt: DateTime.now(),
                                          clientLocalTimestamp: DateTime.now(),
                                        ),
                                        watchTagOnDone: sid,
                                      );
                                },
                              ));
                        }

                        if (isPending) {
                          return Padding(
                            padding: EdgeInsets.only(top: $styles.insets.xs),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: $styles.insets.xs),
                                Text(
                                  $strings.chat_getting_checkins,
                                  style: $styles.text.caption.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // No questions and not pending
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  if (message.clientLocalTimestamp != null) ...[
                    SizedBox(height: $styles.insets.sm),
                    Text(
                      _formatTimestamp(message.clientLocalTimestamp!),
                      style: $styles.text.caption.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return $strings.time_just_now;
    } else if (difference.inHours < 1) {
      return $strings.time_minutes_ago(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return $strings.time_hours_ago(difference.inHours);
    } else {
      return $strings.time_days_ago(difference.inDays);
    }
  }

  Widget _buildHeader(
      BuildContext context, DateTime focusedMonth, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    final viewModel = ref.watch(chatViewModelProvider);

    DateTime sessionDate = DateTime.now();
    if (viewModel.currentSessionMessages.isNotEmpty) {
      final firstMessage = viewModel.currentSessionMessages.first;
      if (firstMessage.clientLocalTimestamp != null) {
        sessionDate = firstMessage.clientLocalTimestamp!;
      } else if (firstMessage.createdAt != null) {
        sessionDate = firstMessage.createdAt;
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
          $styles.insets.md, mq.padding.top, $styles.insets.md, 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularIconButton(
            icon: Icons.arrow_back,
            size: 48,
            iconColor: $styles.colors.black,
            backgroundColor: Colors.transparent,
            onTap: () => context.go(RouteNames.chatHistory),
          ),
          Row(
            children: [
              Icon(Icons.calendar_month),
              SizedBox(width: $styles.insets.sm),
              Text(DateFormat.yMMMMd().format(sessionDate),
                  style: $styles.text.bodySmall),
            ],
          ),
          CircularIconButton(
              size: 48,
              icon: Icons.settings,
              iconColor: $styles.colors.black,
              backgroundColor: Colors.transparent,
              onTap: () => context.go(RouteNames.settings)),
        ],
      ),
    );
  }
}
