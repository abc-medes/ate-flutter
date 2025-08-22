import 'package:flutter/cupertino.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/core/services/session_service.dart';
import 'package:regene/core/services/user_service.dart';
import 'package:regene/core/widgets/input_snackbar.dart';
import 'package:regene/data/models/chat_model.dart';

enum ContextPurpose { auto, memory, aiSettings }

class ContextInput extends ConsumerStatefulWidget {
  final Function(String)? onChanged;
  final bool isDisabled;
  final TextEditingController? controller;

  final String? title;
  final String? subtitle;
  final String? hintText;
  final ContextPurpose? mode;
  final ValueChanged<ContextPurpose>? onModeChanged;

  const ContextInput({
    super.key,
    this.onChanged,
    this.controller,
    this.isDisabled = false,
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

  bool _isSubmitting = false;

  ContextPurpose get _currentMode => widget.mode ?? _mode;

  String get _computedHint {
    if (widget.hintText != null) return widget.hintText!;
    switch (_currentMode) {
      case ContextPurpose.memory:
        return 'What should we know about you?';
      case ContextPurpose.aiSettings:
        return 'Adjust AI preferences (language, tone, style)...';
      case ContextPurpose.auto:
      default:
        return 'Share context or preferences to personalize your experience';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _mode = widget.mode ?? ContextPurpose.auto;
  }

  void _onTextChanged() {
    final cb = widget.onChanged;
    if (cb != null) cb(_controller.text);
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

  Future<void> _createAndSendContextMessage() async {
    final cm = ChatMessageDTO(
      userId: ref.read(userServiceProvider).userId,
      createdAt: DateTime.now(),
      clientLocalTimestamp: DateTime.now(),
      sessionId: ref.read(sessionIdProvider),
      message: _controller.text,
      isUser: true,
      chatOffset: 0,
    );

    setState(() {
      _isSubmitting = true;
    });

    InputSnackbar.showProcessing(context);

    try {
      final res = await ApiService.processMemoryOnly(cm);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final rawResult = res['result'];
      final successMsg = rawResult is String
          ? rawResult.trim().isEmpty
              ? 'Saved to memory'
              : rawResult
          : (rawResult?.toString() ?? 'Saved to memory');

      InputSnackbar.showSuccess(context, message: successMsg);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      InputSnackbar.showError(context);
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _controller.clear();
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (widget.isDisabled || _isSubmitting) return;
    if (_controller.text.trim().isEmpty) return;
    await _createAndSendContextMessage();
  }

  Widget _buildHeader(String title, String subtitle) {
    return Padding(
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
    );
  }

  Widget _buildModePicker() {
    return SizedBox(
      width: $styles.insets.offset,
      height: $styles.insets.xl * 1.2,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(
          initialItem: _currentMode.index,
        ),
        itemExtent: $styles.insets.lg,
        squeeze: 1.5,
        onSelectedItemChanged: (idx) {
          setState(() => _mode = ContextPurpose.values[idx]);
          final onModeChanged = widget.onModeChanged;
          if (onModeChanged != null) onModeChanged(ContextPurpose.values[idx]);
        },
        children: [
          Center(child: Text('Auto', style: $styles.text.bodySmall)),
          Center(child: Text('Mem', style: $styles.text.bodySmall)),
          Center(child: Text('AI', style: $styles.text.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildInputRow(String hint) {
    return Row(
      children: [
        _buildModePicker(),
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
            enabled: !widget.isDisabled && !_isSubmitting,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'Tell us about you';
    final subtitle = widget.subtitle ??
        'What should we know about you? This helps personalize your experience.';
    final hint = _computedHint;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(title, subtitle),
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
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: $styles.insets.sm,
                  vertical: $styles.insets.sm,
                ),
                child: _buildInputRow(hint),
              ),
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
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      tooltip: 'Save context',
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom / 2),
            ],
          ),
        ),
      ],
    );
  }
}
