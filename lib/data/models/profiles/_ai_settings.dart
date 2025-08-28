class AISettings {
  final String tone; // friendly|clinical|casual|coach|empathetic|concise
  final String language; // en|ko|...
  final String formality; // casual|neutral|formal
  final String detailLevel; // low|medium|high
  final String emojiUsage; // off|light|normal|rich
  final String responseLength; // short|medium|long
  final String goalFocus; // weight_loss|sleep|stress|digestion|general
  final String summarizeStyle; // bullet|paragraph

  const AISettings({
    this.tone = 'friendly',
    this.language = 'ko',
    this.formality = 'neutral',
    this.detailLevel = 'medium',
    this.emojiUsage = 'normal',
    this.responseLength = 'medium',
    this.goalFocus = 'general',
    this.summarizeStyle = 'paragraph',
  });

  factory AISettings.fromJson(Map<String, dynamic> json) {
    return AISettings(
      tone: (json['tone'] as String?) ?? 'friendly',
      language: (json['language'] as String?) ?? 'ko',
      formality: (json['formality'] as String?) ?? 'neutral',
      detailLevel: (json['detail_level'] as String?) ?? 'medium',
      emojiUsage: (json['emoji_usage'] as String?) ?? 'normal',
      responseLength: (json['response_length'] as String?) ?? 'medium',
      goalFocus: (json['goal_focus'] as String?) ?? 'general',
      summarizeStyle: (json['summarize_style'] as String?) ?? 'paragraph',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tone': tone,
      'language': language,
      'formality': formality,
      'detail_level': detailLevel,
      'emoji_usage': emojiUsage,
      'response_length': responseLength,
      'goal_focus': goalFocus,
      'summarize_style': summarizeStyle,
    };
  }

  AISettings copyWith({
    String? tone,
    String? language,
    String? formality,
    String? detailLevel,
    String? emojiUsage,
    String? responseLength,
    String? goalFocus,
    String? summarizeStyle,
  }) {
    return AISettings(
      tone: tone ?? this.tone,
      language: language ?? this.language,
      formality: formality ?? this.formality,
      detailLevel: detailLevel ?? this.detailLevel,
      emojiUsage: emojiUsage ?? this.emojiUsage,
      responseLength: responseLength ?? this.responseLength,
      goalFocus: goalFocus ?? this.goalFocus,
      summarizeStyle: summarizeStyle ?? this.summarizeStyle,
    );
  }

  bool get isConfigured => true;
}
