class VectorContext {
  final String? id;
  final String userId;
  final String chatRoomId;
  final String content;
  final List<double> embedding;
  final String type; // 'system_prompt', 'chat_summary', etc.
  final String? topic;
  final String? source; // 'user', 'assistant', 'memory_worker'
  final String? timeBucket;
  final DateTime? createdAt;

  VectorContext({
    this.id,
    required this.userId,
    required this.chatRoomId,
    required this.content,
    required this.embedding,
    required this.type,
    this.topic,
    this.source,
    this.timeBucket,
    this.createdAt,
  });

  factory VectorContext.fromJson(Map<String, dynamic> json) {
    return VectorContext(
      id: json['id'],
      userId: json['user_id'],
      chatRoomId: json['chat_room_id'],
      content: json['content'],
      embedding: List<double>.from(json['embedding']),
      type: json['type'],
      topic: json['topic'],
      source: json['source'],
      timeBucket: json['time_bucket'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'chat_room_id': chatRoomId,
      'content': content,
      'embedding': embedding,
      'type': type,
      if (topic != null) 'topic': topic,
      if (source != null) 'source': source,
      if (timeBucket != null) 'time_bucket': timeBucket,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  VectorContext copyWith({
    String? id,
    String? userId,
    String? chatRoomId,
    String? content,
    List<double>? embedding,
    String? type,
    String? topic,
    String? source,
    String? timeBucket,
    DateTime? createdAt,
  }) {
    return VectorContext(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      content: content ?? this.content,
      embedding: embedding ?? this.embedding,
      type: type ?? this.type,
      topic: topic ?? this.topic,
      source: source ?? this.source,
      timeBucket: timeBucket ?? this.timeBucket,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
