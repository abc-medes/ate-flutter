import 'package:flutter/cupertino.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/services/session_service.dart';
import 'package:regene/core/services/user_service.dart';
import 'package:regene/data/models/chat_model.dart';

enum ContextPurpose { auto, memory, aiSettings }

class ContextInput extends ConsumerStatefulWidget {
  final Function(ChatMessageDTO cm)? onSubmit;
  final Function(String)? onChanged;
  final bool isDisabled;
  final TextEditingController? controller;
  final bool isProcessing;

  // Optional customization for helper area
  final String? title;
  final String? subtitle;
  final String? hintText;
  final ContextPurpose? mode;
  final ValueChanged<ContextPurpose>? onModeChanged;

  const ContextInput({
    super.key,
    this.onSubmit,
    this.onChanged,
    this.controller,
    this.isDisabled = false,
    this.isProcessing = false,
    this.title,
    this.subtitle,
    this.hintText,
    this.mode,
    this.onModeChanged,
  });

  @override
  ConsumerState<ContextInput> createState() => _ContextInputState();
}

class _ContextInputState extends ConsumerState<ContextInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late ContextPurpose _mode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _mode = widget.mode ?? ContextPurpose.auto;
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.removeListener(_onTextChanged);
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _createAndSendContextMessage() {
    final cm = ChatMessageDTO(
      userId: ref.read(userServiceProvider).userId,
      createdAt: DateTime.now(),
      clientLocalTimestamp: DateTime.now(),
      sessionId: ref.read(sessionIdProvider),
      message: _controller.text,
      isUser: true,
      // No time offset for long-term context
    );

    if (widget.onSubmit != null) {
      widget.onSubmit!(cm);
    }

    _controller.clear();
  }

  void _handleSubmit() {
    if (widget.isDisabled || widget.isProcessing) return;
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _createAndSendContextMessage();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final currentMode = widget.mode ?? _mode;
    final title = widget.title ?? 'Tell us about you';
    final subtitle = widget.subtitle ??
        'What should we know about you? This helps personalize your experience.';
    final hint = widget.hintText ??
        (currentMode == ContextPurpose.memory
            ? 'What should we know about you?'
            : currentMode == ContextPurpose.aiSettings
                ? 'Adjust AI preferences (language, tone, style)...'
                : 'Share context or preferences to personalize your experience');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Helper area (title + subtitle)
        Padding(
          padding: EdgeInsets.fromLTRB(
            $styles.insets.md,
            $styles.insets.sm,
            $styles.insets.md,
            $styles.insets.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: $styles.insets.md, color: $styles.colors.accent2),
              SizedBox(width: $styles.insets.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: $styles.text.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: $styles.insets.xs * .5),
                    Text(
                      subtitle,
                      style: $styles.text.bodySmall
                          .copyWith(color: $styles.colors.caption),
                    ),
                  ],
                ),
              ),
            ],
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
              top: BorderSide(color: $styles.colors.accent2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField only (no time picker, no image)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: $styles.insets.sm,
                  vertical: $styles.insets.sm,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: $styles.insets.offset,
                      height: $styles.insets.xl * 1.2,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: currentMode.index,
                        ),
                        itemExtent: $styles.insets.lg,
                        squeeze: 1.5,
                        onSelectedItemChanged: (idx) {
                          setState(() => _mode = ContextPurpose.values[idx]);
                          widget.onModeChanged
                              ?.call(ContextPurpose.values[idx]);
                        },
                        children: [
                          Center(
                              child:
                                  Text('Auto', style: $styles.text.bodySmall)),
                          Center(
                              child:
                                  Text('Mem', style: $styles.text.bodySmall)),
                          Center(
                              child: Text('AI', style: $styles.text.bodySmall)),
                        ],
                      ),
                    ),
                    SizedBox(width: $styles.insets.sm),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: 5,
                        minLines: 1,
                        cursorColor: $styles.colors.accent2,
                        style: $styles.text.bodySmall,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: $styles.text.bodySmall.copyWith(
                            color: $styles.colors.caption,
                          ),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.newline,
                        enabled: !widget.isDisabled && !widget.isProcessing,
                      ),
                    ),
                  ],
                ),
              ),

              // Action row with send
              Padding(
                padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: $styles.colors.accent2,
                      ),
                      onPressed: (widget.isDisabled || widget.isProcessing)
                          ? null
                          : _handleSubmit,
                      tooltip: 'Save context',
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
