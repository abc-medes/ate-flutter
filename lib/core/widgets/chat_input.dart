import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _chatInputController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();

  @override
  void dispose() {
    _chatInputController.dispose();
    _chatFocusNode.dispose();
    super.dispose();
  }

  void _onChatSubmit(String text) {}

  void _handleSubmit() {
    final text = _chatInputController.text;
    if (text.trim().isEmpty) return;

    _onChatSubmit(text);
    _chatInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _chatInputController,
            focusNode: _chatFocusNode,
            decoration: InputDecoration(
              hintText: 'Ask a health question...',
              filled: true,
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
      ],
    );
  }
}
