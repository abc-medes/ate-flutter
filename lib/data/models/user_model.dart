import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final UserPreferences preferences;
  final OnboardingStatus onboardingStatus;
  final HealthProfile healthProfile;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.lastSignInAt,
    required this.preferences,
    required this.onboardingStatus,
    required this.healthProfile,
  });

  // Check if user has completed onboarding
  bool get isOnboardingCompleted => onboardingStatus.isCompleted;

  // Create a User from Supabase Auth user data and additional profile data
  factory User.fromSupabase(
      supabase.User supabaseUser, Map<String, dynamic> profileData) {
    // Handle createdAt and lastSignInAt with proper conversion
    DateTime getDateTime(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) return DateTime.parse(dateValue);
      return DateTime.now();
    }

    final createdAt = getDateTime(supabaseUser.createdAt);
    final lastSignInAt = getDateTime(supabaseUser.lastSignInAt);

    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: profileData['name'],
      avatarUrl: profileData['avatar_url'],
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
      preferences: UserPreferences.fromJson(profileData['preferences'] ?? {}),
      onboardingStatus:
          OnboardingStatus.fromJson(profileData['onboarding_status'] ?? {}),
      healthProfile:
          HealthProfile.fromJson(profileData['health_profile'] ?? {}),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastSignInAt.toIso8601String(),
      'preferences': preferences.toJson(),
      'onboarding_status': onboardingStatus.toJson(),
      'health_profile': healthProfile.toJson(),
    };
  }

  // Create a copy with updated fields
  User copyWith({
    String? name,
    String? avatarUrl,
    UserPreferences? preferences,
    OnboardingStatus? onboardingStatus,
    HealthProfile? healthProfile,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
      preferences: preferences ?? this.preferences,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      healthProfile: healthProfile ?? this.healthProfile,
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
}

class OnboardingStatus {
  final bool personalInfoCompleted;
  final bool healthProfileCompleted;
  final bool goalsCompleted;
  final DateTime? completedAt;

  OnboardingStatus({
    this.personalInfoCompleted = false,
    this.healthProfileCompleted = false,
    this.goalsCompleted = false,
    this.completedAt,
  });

  // Check if all onboarding steps are completed
  bool get isCompleted =>
      personalInfoCompleted && healthProfileCompleted && goalsCompleted;

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      personalInfoCompleted: json['personal_info_completed'] ?? false,
      healthProfileCompleted: json['health_profile_completed'] ?? false,
      goalsCompleted: json['goals_completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personal_info_completed': personalInfoCompleted,
      'health_profile_completed': healthProfileCompleted,
      'goals_completed': goalsCompleted,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  OnboardingStatus copyWith({
    bool? personalInfoCompleted,
    bool? healthProfileCompleted,
    bool? goalsCompleted,
    DateTime? completedAt,
  }) {
    return OnboardingStatus(
      personalInfoCompleted:
          personalInfoCompleted ?? this.personalInfoCompleted,
      healthProfileCompleted:
          healthProfileCompleted ?? this.healthProfileCompleted,
      goalsCompleted: goalsCompleted ?? this.goalsCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Mark a specific step as completed
  OnboardingStatus completeStep(String step) {
    switch (step) {
      case 'personal_info':
        return copyWith(personalInfoCompleted: true);
      case 'health_profile':
        return copyWith(healthProfileCompleted: true);
      case 'goals':
        return copyWith(goalsCompleted: true);
      default:
        return this;
    }
  }

  // Mark all steps as completed
  OnboardingStatus completeAll() {
    return OnboardingStatus(
      personalInfoCompleted: true,
      healthProfileCompleted: true,
      goalsCompleted: true,
      completedAt: DateTime.now(),
    );
  }
}

class HealthProfile {
  final double? height; // in cm
  final double? weight; // in kg
  final DateTime? dateOfBirth;
  final String? gender;

  HealthProfile({
    this.height,
    this.weight,
    this.dateOfBirth,
    this.gender,
  });

  // Calculate BMI if height and weight are available
  double? get bmi {
    if (height == null || weight == null || height == 0) return null;
    return weight! / ((height! / 100) * (height! / 100));
  }

  // Calculate age if date of birth is available
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }

  HealthProfile copyWith({
    double? height,
    double? weight,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return HealthProfile(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  // Check if all essential health data is provided
  bool get isComplete =>
      height != null && weight != null && dateOfBirth != null && gender != null;
}
