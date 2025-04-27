import 'package:ate_project/core/widgets/ai_response_bottom_sheet.dart';
import 'package:flutter/material.dart';

class HealthChatInput extends StatefulWidget {
  const HealthChatInput({
    super.key,
  });

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

  void _onChatSubmit(String text) {
    print('User query: $text');

    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('AI is processing your question...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    // Delay for 5 seconds then show the AI response
    Future.delayed(const Duration(seconds: 1), () {
      AIResponseBottomSheet.show(context, text);
    });
  }

  void _handleSubmit() {
    final text = _chatInputController.text;
    if (text.trim().isEmpty) return;

    _onChatSubmit(text);
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
