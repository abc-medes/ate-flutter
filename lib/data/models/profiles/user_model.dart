import 'package:regene/data/models/profiles/_ai_settings.dart';
import 'package:regene/data/models/profiles/_app_open_state.dart';
import 'package:regene/data/models/profiles/_notification_settings.dart';
import 'package:regene/data/models/profiles/_user_preferences.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final UserPreferences preferences;
  final OpenState appOpenState;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.lastSignInAt,
    required this.preferences,
    required this.appOpenState,
  });

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
        aiSettings: AISettings(),
      ),
      appOpenState: OpenState(),
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      lastSignInAt: DateTime.parse(json['last_sign_in_at']),
      preferences: UserPreferences.fromJson(json['preferences']),
      appOpenState: OpenState.fromJson(json['app_open_state']),
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
      'app_open_state': appOpenState.toJson(),
    };
  }

  User copyWith({
    String? name,
    String? avatarUrl,
    UserPreferences? preferences,
    OpenState? appOpenState,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
      preferences: preferences ?? this.preferences,
      appOpenState: appOpenState ?? this.appOpenState,
    );
  }
}
