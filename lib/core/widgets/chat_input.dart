import 'package:flutter/material.dart';

class HealthChatInput extends StatefulWidget {
  final Function(String) onSubmit;

  const HealthChatInput({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<HealthChatInput> createState() => _HealthChatInputState();
}

class _HealthChatInputState extends State<HealthChatInput> {
  final TextEditingController _chatInputController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();

  @override
  void dispose() {
    _chatInputController.dispose();
    _chatFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _chatInputController.text;
    if (text.trim().isEmpty) return;

    widget.onSubmit(text);
    _chatInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatInputController,
              focusNode: _chatFocusNode,
              decoration: InputDecoration(
                hintText: 'Ask a health question...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleSubmit(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.white,
              onPressed: _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
