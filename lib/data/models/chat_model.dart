class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? userId;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.userId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['message'] as String,
      isUser: json['is_user'] as bool,
      userId: json['user_id'] as String?,
      timestamp: DateTime.parse(json['created_at'] as String),
    );
  }

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? userId,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }
}
