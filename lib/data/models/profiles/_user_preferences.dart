import 'package:regene/data/models/profiles/_notification_settings.dart';

class UserPreferences {
  final bool darkMode;
  final String? language;
  final NotificationSettings notificationSettings;

  UserPreferences({
    this.darkMode = false,
    this.language,
    required this.notificationSettings,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['dark_mode'] ?? false,
      language: json['language'],
      notificationSettings:
          NotificationSettings.fromJson(json['notification_settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dark_mode': darkMode,
      'language': language,
      'notification_settings': notificationSettings.toJson(),
    };
  }

  UserPreferences copyWith({
    bool? darkMode,
    String? language,
    NotificationSettings? notificationSettings,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}
