import 'package:bodai/data/models/profiles/_notification_settings.dart';
import 'package:bodai/data/models/profiles/_ai_settings.dart';

class UserPreferences {
  final bool darkMode;
  final String? language;
  final NotificationSettings notificationSettings;
  final AISettings aiSettings;

  UserPreferences({
    this.darkMode = false,
    this.language,
    required this.notificationSettings,
    required this.aiSettings,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['dark_mode'] ?? false,
      language: json['language'],
      notificationSettings:
          NotificationSettings.fromJson(json['notification_settings'] ?? {}),
      aiSettings: AISettings.fromJson(json['ai_settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dark_mode': darkMode,
      'language': language,
      'notification_settings': notificationSettings.toJson(),
      'ai_settings': aiSettings.toJson(),
    };
  }

  UserPreferences copyWith({
    bool? darkMode,
    String? language,
    NotificationSettings? notificationSettings,
    AISettings? aiSettings,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      aiSettings: aiSettings ?? this.aiSettings,
    );
  }
}
