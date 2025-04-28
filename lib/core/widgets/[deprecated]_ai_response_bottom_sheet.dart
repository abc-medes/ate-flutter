import 'package:flutter/material.dart';

class AIResponseBottomSheet {
  static void show(BuildContext context, String userQuestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        minHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AIResponseChatView(initialQuestion: userQuestion),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIResponseChatView extends StatefulWidget {
  final String initialQuestion;

  const AIResponseChatView({
    super.key,
    required this.initialQuestion,
  });

  @override
  State<AIResponseChatView> createState() => _AIResponseChatViewState();
}

class _AIResponseChatViewState extends State<AIResponseChatView> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add initial messages
    _addMessage(widget.initialQuestion, true);
    _generateResponse(widget.initialQuestion);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });

    // Scroll to bottom after message is added
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _generateResponse(String question) {
    // Mock AI responses based on common health questions
    String response;

    // Simulate AI thinking with a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (question.toLowerCase().contains('hamburger')) {
        response =
            '''Based on the health information you've provided, I can offer some general guidance about eating a hamburger:

While an occasional hamburger can be part of a balanced diet, there are a few considerations:

1. **Portion size matters**: A single regular-sized burger is preferable to oversized options.

2. **Consider your toppings**: Vegetables add nutrients, while excessive cheese, bacon, and mayo add calories and saturated fat.

3. **Bun choices**: Whole grain buns provide more fiber than white buns.

4. **Side dish choices**: Consider a side salad instead of fries for a healthier meal overall.

5. **Cooking method**: Grilled is generally healthier than fried.

If you have specific health conditions like heart disease, high cholesterol, or are on a weight management plan, you might want to limit red meat consumption.

Remember, moderation is key - an occasional hamburger is unlikely to cause harm in the context of an otherwise balanced diet.''';
      } else {
        // Generic response for other health questions
        response =
            '''Thank you for your health question. Based on general health guidelines:

1. Everyone's health needs are different, and what works for one person may not work for another.

2. It's important to maintain a balanced diet rich in fruits, vegetables, whole grains, lean proteins, and healthy fats.

3. Regular physical activity is recommended for most people.

4. Adequate sleep and stress management are crucial components of overall health.

5. For personalized health advice, it's always best to consult with a healthcare professional who knows your specific health history.

Would you like more information on any specific aspect of your health question?''';
      }

      _addMessage(response, false);
    });
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _addMessage(text, true);
    _textController.clear();
    _generateResponse(text);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 1,
      builder: (_, controller) => Stack(
        children: [
          Column(
            children: [
              // Handle bar for dragging
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title with health icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Health AI Chat',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(color: Colors.grey[300], height: 24),
              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                      20, 0, 20, 100), // Extra padding at bottom for input
                  itemCount: _messages.length + 1, // +1 for disclaimer
                  itemBuilder: (context, index) {
                    if (index < _messages.length) {
                      final message = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: message.isUser
                            ? _buildUserMessage(message.text)
                            : _buildAIMessage(message.text),
                      );
                    } else {
                      // Disclaimer at the end
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This information is general guidance and not medical advice. For specific health concerns, please consult a healthcare professional.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          // Input field at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ask another health question...',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildAIMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.smart_toy,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
