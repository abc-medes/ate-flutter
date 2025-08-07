import 'package:flutter/cupertino.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/services/session_service.dart';
import 'package:regene/core/services/user_service.dart';
import 'package:regene/data/models/chat_model.dart';

class ChatInput extends ConsumerStatefulWidget {
  final Function(ChatMessageDTO cm)? onSubmit;
  final Function(String)? onChanged;
  final bool isDisabled;
  final TextEditingController? controller;
  final bool shouldSaveAsContext;
  final VoidCallback? onSaveModeToggle;
  final String? sessionId;
  final bool isProcessing;

  const ChatInput({
    super.key,
    this.onSubmit,
    this.onChanged,
    this.controller,
    this.isDisabled = false,
    this.shouldSaveAsContext = false,
    this.onSaveModeToggle,
    this.sessionId,
    this.isProcessing = false,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  late TextEditingController _chatInputController;
  final FocusNode _chatFocusNode = FocusNode();
  List<String> _selectedImages = [];
  int _selectedHour = 0;

  @override
  void initState() {
    super.initState();
    _chatInputController = widget.controller ?? TextEditingController();
    _chatInputController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_chatInputController.text);
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it
    if (widget.controller == null) {
      _chatInputController.removeListener(_onTextChanged);
      _chatInputController.dispose();
    }
    _chatFocusNode.dispose();
    super.dispose();
  }

  void _handleImageSelection() async {
    setState(() {
      _selectedImages.add("image_${_selectedImages.length + 1}");
    });
  }

  void _createAndSendChatMessage() {
    final cm = ChatMessageDTO(
      userId: ref.read(userServiceProvider).userId,
      createdAt: DateTime.now(),
      clientLocalTimestamp: DateTime.now(),
      sessionId: ref.read(sessionIdProvider),
      message: _chatInputController.text,
      isUser: true,
      chatOffset: _selectedHour,
    );

    if (widget.onSubmit != null) {
      widget.onSubmit!(cm);
    }

    _chatInputController.clear();
    setState(() {
      _selectedImages = [];
    });
  }

  void _handleSubmit() {
    if (widget.isDisabled) return;
    final text = _chatInputController.text;
    if (text.trim().isEmpty && _selectedImages.isEmpty) return;

    _createAndSendChatMessage();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selected images preview
        if (_selectedImages.isNotEmpty)
          Container(
            height: $styles.insets.offset,
            margin: EdgeInsets.only(bottom: $styles.insets.sm),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: $styles.insets.offset,
                  margin: EdgeInsets.only(right: $styles.insets.xs),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular($styles.corners.md),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Text(
                          "Image ${index + 1}",
                          style: $styles.text.caption.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, size: $styles.insets.sm),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        Container(
          decoration: BoxDecoration(
            color: $styles.colors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular($styles.insets.lg),
              topRight: Radius.circular($styles.insets.lg),
            ),
            border: Border(
              top: BorderSide(color: $styles.colors.accent1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: $styles.insets.sm, vertical: $styles.insets.sm),
                child: Row(
                  children: [
                    // 시간 선택 Picker
                    SizedBox(
                      width: $styles.insets.offset,
                      height: $styles.insets.xl * 1.2,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: _selectedHour,
                        ),
                        itemExtent: $styles.insets.lg,
                        squeeze: 1.5,
                        onSelectedItemChanged: (idx) =>
                            setState(() => _selectedHour = idx),
                        children: [
                          Center(
                            child: Text(
                              '현재',
                              style: $styles.text.bodySmall,
                            ),
                          ),
                          for (int h = 1; h <= 10; h++)
                            Text('${h}h ago', style: $styles.text.bodySmall),
                        ],
                      ),
                    ),
                    SizedBox(width: $styles.insets.sm),

                    // Expanded TextField
                    Expanded(
                      child: TextField(
                        controller: _chatInputController,
                        focusNode: _chatFocusNode,
                        maxLines: 5,
                        minLines: 1,
                        cursorColor: widget.shouldSaveAsContext
                            ? $styles.colors.accent2
                            : $styles.colors.accent1,
                        style: $styles.text.bodySmall,
                        decoration: InputDecoration(
                          hintText: widget.shouldSaveAsContext
                              ? 'Tell me what you want to remember...'
                              : 'How was your health day?',
                          hintStyle: $styles.text.bodySmall
                              .copyWith(color: $styles.colors.caption),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons (always visible)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: $styles.insets.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.shouldSaveAsContext
                                ? Icons.save
                                : Icons.save_outlined,
                            color: widget.shouldSaveAsContext
                                ? $styles.colors.accent2
                                : $styles.colors.accent1,
                          ),
                          onPressed: widget.onSaveModeToggle,
                          tooltip: widget.shouldSaveAsContext
                              ? 'Saving as context'
                              : 'Save as temporary chat',
                        ),
                        if (!widget.shouldSaveAsContext)
                          IconButton(
                            icon: Icon(
                              Icons.image,
                              color: widget.shouldSaveAsContext
                                  ? $styles.colors.accent2
                                  : $styles.colors.accent1,
                            ),
                            onPressed: _handleImageSelection,
                            tooltip: 'Add image',
                          ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: widget.shouldSaveAsContext
                            ? $styles.colors.accent2
                            : $styles.colors.accent1,
                      ),
                      onPressed: _handleSubmit,
                      tooltip: 'Send message',
                    ),
                  ],
                ),
              ),
              SizedBox(height: mq.padding.bottom / 2),
            ],
          ),
        ),
      ],
    );
  }
}
