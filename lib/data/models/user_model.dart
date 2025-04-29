import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final UserPreferences preferences;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.lastSignInAt,
    required this.preferences,
  });

  factory User.fromSupabase(
      supabase.User supabaseUser, Map<String, dynamic> profileData) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: profileData['name'],
      avatarUrl: profileData['avatar_url'],
      createdAt: supabaseUser.createdAt as DateTime,
      lastSignInAt: supabaseUser.lastSignInAt as DateTime,
      preferences: UserPreferences.fromJson(profileData['preferences'] ?? {}),
    );
  }

  factory User.newUser({
    required String id,
    required String email,
    required String name,
  }) {
    final now = DateTime.now();

    return User(
      id: id,
      email: email,
      name: name,
      avatarUrl: null,
      createdAt: now,
      lastSignInAt: now,
      preferences: UserPreferences(
        notificationSettings: NotificationSettings(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastSignInAt.toIso8601String(),
      'preferences': preferences.toJson(),
    };
  }

  User copyWith({
    String? name,
    String? avatarUrl,
    UserPreferences? preferences,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

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

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;

  NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['push_enabled'] ?? true,
      emailEnabled: json['email_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
    );
  }
}
