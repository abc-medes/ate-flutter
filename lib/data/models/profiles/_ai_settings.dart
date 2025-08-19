class AISettings {
  final String? language;
  final String? communicationStyle;
  final Map<String, dynamic> healthContext;
  final Map<String, dynamic> personalityTraits;
  final DateTime? lastUpdated;

  AISettings({
    this.language,
    this.communicationStyle,
    this.healthContext = const {},
    this.personalityTraits = const {},
    this.lastUpdated,
  });

  factory AISettings.fromJson(Map<String, dynamic> json) {
    return AISettings(
      language: json['language'],
      communicationStyle: json['communication_style'],
      healthContext: json['health_context'] ?? {},
      personalityTraits: json['personality_traits'] ?? {},
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'communication_style': communicationStyle,
      'health_context': healthContext,
      'personality_traits': personalityTraits,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  AISettings copyWith({
    String? language,
    String? communicationStyle,
    Map<String, dynamic>? healthContext,
    Map<String, dynamic>? personalityTraits,
    DateTime? lastUpdated,
  }) {
    return AISettings(
      language: language ?? this.language,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      healthContext: healthContext ?? this.healthContext,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper methods for specific health context
  String? get smokingHistory => healthContext['smoking_history'];
  String? get alcoholConsumption => healthContext['alcohol_consumption'];
  String? get exerciseHabits => healthContext['exercise_habits'];
  String? get dietaryRestrictions => healthContext['dietary_restrictions'];
  String? get medicalConditions => healthContext['medical_conditions'];
  String? get medications => healthContext['medications'];

  // Helper methods for personality traits
  String? get preferredTone => personalityTraits['preferred_tone'];
  String? get formalityLevel => personalityTraits['formality_level'];
  String? get humorPreference => personalityTraits['humor_preference'];
  String? get detailLevel => personalityTraits['detail_level'];

  // Check if settings are configured
  bool get isConfigured =>
      language != null ||
      communicationStyle != null ||
      healthContext.isNotEmpty ||
      personalityTraits.isNotEmpty;
}
