class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime localTimestamp;
  final int? hour;

  ChatMessage({
    required this.message,
    required this.isUser,
    DateTime? localTimestamp,
    this.hour,
  }) : localTimestamp = localTimestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] as String,
      isUser: json['is_user'] as bool,
      localTimestamp: DateTime.parse(json['local_timestamp_str'] as String),
      hour: json['hour'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'is_user': isUser,
      'local_timestamp_str': localTimestamp.toIso8601String(),
      'hour': hour,
    };
  }

  ChatMessage copyWith({
    String? message,
    bool? isUser,
    DateTime? localTimestamp,
    int? hour,
  }) {
    return ChatMessage(
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      localTimestamp: localTimestamp ?? this.localTimestamp,
      hour: hour ?? this.hour ?? 0,
    );
  }
}
