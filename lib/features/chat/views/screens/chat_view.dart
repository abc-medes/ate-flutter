import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/core/widgets/chat_input.dart';
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
  @override
  void initState() {
    super.initState();
    // Initialize the chat with the view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).initializeChat(
            selectedSessionId: widget.selectedSessionId,
            initialMessage: widget.initialMessage,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(chatViewModelProvider);
    final viewModelNotifier = ref.read(chatViewModelProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.go(RouteNames.chatHistory);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.go(RouteNames.chatHistory);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: viewModel.isLoading &&
                      viewModel.currentSessionMessages.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : viewModel.error != null
                      ? Center(child: Text('Error: ${viewModel.error}'))
                      : ListView.builder(
                          padding: EdgeInsets.all($styles.insets.md),
                          itemCount: viewModel.currentSessionMessages.length,
                          itemBuilder: (context, index) {
                            final message =
                                viewModel.currentSessionMessages[index];
                            return Container(
                              margin:
                                  EdgeInsets.only(bottom: $styles.insets.sm),
                              child: Row(
                                mainAxisAlignment: message.isUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7,
                                    ),
                                    padding: EdgeInsets.all($styles.insets.sm),
                                    decoration: BoxDecoration(
                                      color: message.isUser
                                          ? $styles.colors.accent1
                                          : $styles.colors.caption,
                                      borderRadius: BorderRadius.circular(
                                          $styles.corners.md),
                                    ),
                                    child: Text(
                                      message.message ?? '',
                                      style: $styles.text.bodySmall
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            ChatInput(
              onSubmit: (ChatMessageDTO message) {
                viewModelNotifier.sendMessage(message);
              },
              isProcessing: viewModel.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
