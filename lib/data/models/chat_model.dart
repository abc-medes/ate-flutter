class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool shouldSaveAsContext;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.shouldSaveAsContext = false,
  }) : timestamp = timestamp ?? DateTime.now();
}
