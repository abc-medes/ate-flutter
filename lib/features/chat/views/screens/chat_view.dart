import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/core/widgets/chat_input.dart';
import 'package:regene/core/widgets/circular_icon_button.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/features/chat/view_models/chat_history_view_model.dart';
import 'package:regene/features/chat/view_models/chat_view_model.dart';

class ChatView extends ConsumerStatefulWidget {
  final String? selectedSessionId;
  final ChatMessageDTO? initialMessage;

  const ChatView({
    super.key,
    this.selectedSessionId,
    this.initialMessage,
  });

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize the chat with the view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).initializeChat(
            selectedSessionId: widget.selectedSessionId,
            initialMessage: widget.initialMessage,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      controller: _scrollController,
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
            onTap: () => context.go(RouteNames.chatHistory),
          ),
          Row(
            children: [
              Icon(Icons.calendar_month),
              SizedBox(width: $styles.insets.sm),
              Text(DateFormat.yMMMMd().format(DateTime.now()),
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
