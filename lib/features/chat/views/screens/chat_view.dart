import 'package:intl/intl.dart';
import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/chat_input.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:bodido/features/chat/view_models/chat_view_model.dart';

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

  @override
  void initState() {
    super.initState();

    // Initialize page controller with the selected session index
    if (widget.sessionIds != null && widget.sessionIds!.isNotEmpty) {
      _currentPageIndex = 0; // Always start with first session
    }

    _pageController = PageController(initialPage: _currentPageIndex);

    // Initialize the chat with the view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.sessionIds != null && widget.sessionIds!.isNotEmpty) {
        ref.read(chatViewModelProvider.notifier).initializeChat(
              selectedSessionId: widget.sessionIds!.first,
              initialMessage: widget.initialMessage,
            );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(chatViewModelProvider);
    final viewModelNotifier = ref.read(chatViewModelProvider.notifier);

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
              viewModelNotifier.sendMessage(message);
            },
            isProcessing: viewModel.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicScrollView(ChatViewState viewModel) {
    if (widget.sessionIds == null || widget.sessionIds!.isEmpty) {
      // Single session mode - show messages directly
      if (viewModel.currentSessionMessages.isEmpty) {
        return Center(
          child: Text(
            'No messages yet',
            style: $styles.text.body.copyWith(
              color: $styles.colors.caption,
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: List.generate(
            viewModel.currentSessionMessages.length,
            (index) {
              final message = viewModel.currentSessionMessages[index];
              return _buildMessageItem(message, index);
            },
          ),
        ),
      );
    }

    // Multiple sessions mode - show PageView with guide text
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
              // Load messages for the new session
              final sessionId = widget.sessionIds![index];
              ref
                  .read(chatViewModelProvider.notifier)
                  .loadMessagesForSession(sessionId);
            },
            itemBuilder: (context, index) {
              final sessionId = widget.sessionIds![index];
              final isCurrentSession = sessionId == viewModel.currentSessionId;

              if (isCurrentSession) {
                // Show messages for current session
                if (viewModel.currentSessionMessages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages in this session',
                      style: $styles.text.body.copyWith(
                        color: $styles.colors.caption,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      viewModel.currentSessionMessages.length,
                      (messageIndex) {
                        final message =
                            viewModel.currentSessionMessages[messageIndex];
                        return _buildMessageItem(message, messageIndex);
                      },
                    ),
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
                        'Loading session ${index + 1}',
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
                  '좌우로 스와이프하여 다른 채팅 보기',
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
    );
  }

  Widget _buildMessageItem(ChatMessageDTO message, int index) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.lg,
        vertical: $styles.insets.sm,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
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
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Message text
                Text(
                  message.message ?? '',
                  style: $styles.text.h3.copyWith(
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: message.isUser ? TextAlign.right : TextAlign.left,
                ),

                // Timestamp
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
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildHeader(
      BuildContext context, DateTime focusedMonth, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    final viewModel = ref.watch(chatViewModelProvider);

    // Get the session date from the first message, or use current date as fallback
    DateTime sessionDate = DateTime.now();
    if (viewModel.currentSessionMessages.isNotEmpty) {
      final firstMessage = viewModel.currentSessionMessages.first;
      if (firstMessage.clientLocalTimestamp != null) {
        sessionDate = firstMessage.clientLocalTimestamp!;
      } else if (firstMessage.createdAt != null) {
        sessionDate = firstMessage.createdAt!;
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB($styles.insets.md, mq.padding.top,
          $styles.insets.md, $styles.insets.md),
      child: Column(
        children: [
          Row(
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
          // Page indicator for multiple sessions
          if (widget.sessionIds != null && widget.sessionIds!.length > 1) ...[
            SizedBox(height: $styles.insets.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Session ${_currentPageIndex + 1} of ${widget.sessionIds!.length}',
                  style: $styles.text.caption.copyWith(
                    color: $styles.colors.caption,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
