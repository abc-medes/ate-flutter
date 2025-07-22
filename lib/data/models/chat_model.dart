class ChatMessage {
  final String sessionId;
  final String message;
  final bool isUser;
  final DateTime localTimestamp;
  final int? chatOffset;

  ChatMessage({
    required this.sessionId,
    required this.message,
    required this.isUser,
    DateTime? localTimestamp,
    this.chatOffset,
  }) : localTimestamp = localTimestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sessionId: json['session_id'] as String,
      message: json['message'] as String,
      isUser: json['is_user'] as bool,
      localTimestamp: DateTime.parse(json['local_timestamp_str'] as String),
      chatOffset: json['chat_offset'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'message': message,
      'is_user': isUser,
      'local_timestamp_str': localTimestamp.toIso8601String(),
      'chat_offset': chatOffset,
    };
  }

  ChatMessage copyWith({
    String? sessionId,
    String? message,
    bool? isUser,
    DateTime? localTimestamp,
    int? chatOffset,
  }) {
    return ChatMessage(
      sessionId: sessionId ?? this.sessionId,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      localTimestamp: localTimestamp ?? this.localTimestamp,
      chatOffset: chatOffset ?? this.chatOffset,
    );
  }
}

class ChatMessageDTO {
  final int? id;
  final String userId;
  final String sessionId;
  final String message;
  final bool isUser;
  final DateTime createdAt;
  final DateTime? clientLocalTimestamp;
  final int? chatOffset;

  ChatMessageDTO({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.message,
    required this.isUser,
    required this.createdAt,
    this.clientLocalTimestamp,
    this.chatOffset,
  });

  factory ChatMessageDTO.fromJson(Map<String, dynamic> json) {
    return ChatMessageDTO(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      sessionId: json['session_id'] as String,
      message: json['message'] as String,
      isUser: json['is_user'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      clientLocalTimestamp: json['client_local_timestamp_iso'] != null
          ? DateTime.parse(json['client_local_timestamp_iso'] as String)
          : null,
      chatOffset: json['chat_offset'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'message': message,
      'is_user': isUser,
      'created_at': createdAt.toIso8601String(),
      'client_local_timestamp_iso': clientLocalTimestamp?.toIso8601String(),
      'chat_offset': chatOffset,
    };
  }

  ChatMessageDTO copyWith({
    int? id,
    String? userId,
    String? sessionId,
    String? message,
    bool? isUser,
    DateTime? createdAt,
    DateTime? clientLocalTimestamp,
    bool? setClientLocalTimestampNull,
    int? chatOffset,
    bool? setChatOffsetNull,
  }) {
    return ChatMessageDTO(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      clientLocalTimestamp: setClientLocalTimestampNull == true
          ? null
          : clientLocalTimestamp ?? this.clientLocalTimestamp,
      chatOffset:
          setChatOffsetNull == true ? null : chatOffset ?? this.chatOffset,
    );
  }
}
