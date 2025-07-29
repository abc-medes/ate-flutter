import 'package:intl/intl.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/core/services/session_service.dart';
import 'package:regene/core/widgets/chat_input.dart';
import 'package:regene/core/widgets/circular_icon_button.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/features/chat/view_models/chat_view_model.dart';

class ChatView extends ConsumerStatefulWidget {
  final String? initialMessage;
  final int? initialChatOffset;

  const ChatView({
    super.key,
    this.initialMessage,
    this.initialChatOffset,
  });

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        final notifier = ref.read(chatViewModelProvider.notifier);
        final sessionId = ref.read(sessionIdProvider);
        final newMessage = ChatMessage(
          sessionId: sessionId,
          message: widget.initialMessage!,
          chatOffset: widget.initialChatOffset ?? 0,
          isUser: true,
        );
        notifier.sendPrompt(newMessage);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    return Scaffold(
      body: Column(
        children: [
          _TopHeader(),
          Expanded(
            child: _ChatPage(
              messages: state.currentSessionMessages,
              showInput: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        mq.padding.top,
        $styles.insets.md,
        $styles.insets.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularIconButton(
            icon: Icons.arrow_back,
            size: 48,
            onTap: () => context.go(RouteNames.home),
          ),
          Text('CHAT HISTORY', style: $styles.text.body),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ChatPage extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool showInput;
  final ValueChanged<String>? onSendMessage;

  const _ChatPage({
    super.key,
    required this.messages,
    this.showInput = false,
    this.onSendMessage,
  });

  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  late final ScrollController _scrollController;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll to bottom after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant _ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to bottom only if the message list has changed
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: $styles.times.fast,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the date of the first message
        if (widget.messages.isNotEmpty)
          Padding(
            padding: EdgeInsets.all($styles.insets.sm),
            child: Text(
              DateFormat('MMM d, yyyy')
                  .format(widget.messages.first.localTimestamp),
              style: $styles.text.bodySmall,
            ),
          ),
        // Chat bubbles
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            itemCount: widget.messages.length,
            itemBuilder: (_, i) {
              final m = widget.messages[i];
              final align =
                  m.isUser ? Alignment.centerRight : Alignment.centerLeft;
              final bubbleColor = m.isUser
                  ? $styles.colors.accent1.withOpacity(.15)
                  : $styles.colors.accent3;

              return Align(
                alignment: align,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: EdgeInsets.only(bottom: $styles.insets.sm),
                  padding: EdgeInsets.all($styles.insets.sm),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(m.message),
                ),
              );
            },
          ),
        ),
        // Input field for the live chat page
        if (widget.showInput)
          ChatInput(
            onSubmit: (cm) {
              if (widget.onSendMessage != null) {
                widget.onSendMessage!(cm.message);
              }
            },
          ),
      ],
    );
  }
}
