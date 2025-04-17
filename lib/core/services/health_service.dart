import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/data/models/health_model.dart';
import 'package:ate_project/data/repositories/health_repository.dart';

// State class to hold health data and loading/error status
class HealthState {
  final HealthMetrics? healthMetrics;
  final bool isLoading;
  final String? errorMessage;

  HealthState({
    this.healthMetrics,
    this.isLoading = false,
    this.errorMessage,
  });

  // Create a copy with updated fields
  HealthState copyWith({
    HealthMetrics? healthMetrics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HealthState(
      healthMetrics: healthMetrics ?? this.healthMetrics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Check if health data exists
  bool get hasHealthData => healthMetrics != null;
}

// Provider to create and access the repository
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

// Health data state notifier
class HealthNotifier extends StateNotifier<HealthState> {
  final HealthRepository _repository;

  HealthNotifier(this._repository) : super(HealthState()) {
    // Load health data when notifier is created
    loadHealthData();
  }

  // Load health data from the repository
  Future<void> loadHealthData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final healthMetrics = await _repository.getHealthData();
      state = state.copyWith(
        healthMetrics: healthMetrics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load health data: $e',
      );
    }
  }

  // Add a food intake entry
  Future<void> addFoodIntake(FoodIntake foodIntake) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.addFoodIntake(foodIntake);
      if (success) {
        await loadHealthData(); // Reload data
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to add food intake',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error adding food intake: $e',
      );
    }
  }

  // Update activity data
  Future<void> updateActivityData(PhysicalActivityData activityData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.updateActivityData(activityData);
      if (success) {
        await loadHealthData(); // Reload data
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update activity data',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating activity data: $e',
      );
    }
  }

  // Update environmental data
  Future<void> updateEnvironmentalData(
      EnvironmentalData environmentalData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success =
          await _repository.updateEnvironmentalData(environmentalData);
      if (success) {
        await loadHealthData(); // Reload data
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update environmental data',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating environmental data: $e',
      );
    }
  }

  // Update user input data
  Future<void> updateUserInputData(UserInputData userInputData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.updateUserInputData(userInputData);
      if (success) {
        await loadHealthData(); // Reload data
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update user data',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating user data: $e',
      );
    }
  }

  // Generate health suggestions based on missing or outdated data
  List<HealthSuggestion> generateSuggestions() {
    final suggestions = <HealthSuggestion>[];
    final healthMetrics = state.healthMetrics;

    if (healthMetrics == null) {
      // First-time user suggestions
      suggestions.add(
        HealthSuggestion(
          icon: Icons.person,
          label: 'Complete your profile',
          description: 'Add your basic health information',
          category: 'profile',
        ),
      );
      suggestions.add(
        HealthSuggestion(
          icon: Icons.food_bank,
          label: 'Track your first meal',
          description: 'Add a photo of what you\'re eating',
          category: 'nutrition',
        ),
      );
      suggestions.add(
        HealthSuggestion(
          icon: Icons.air,
          label: '미세먼지 (Air quality)',
          description: 'Check today\'s air quality',
          category: 'environmental',
        ),
      );
      return suggestions;
    }

    final now = DateTime.now();

    // Check for missing or outdated nutrition data
    final nutritionData = healthMetrics.userInputData.nutritionData;
    final recentMeals = nutritionData?.recentMeals;
    final bool hasMealToday = recentMeals != null &&
        recentMeals.isNotEmpty &&
        recentMeals[0].timestamp.day == now.day;

    if (!hasMealToday) {
      suggestions.add(
        HealthSuggestion(
          icon: Icons.food_bank,
          label: 'Log today\'s meal',
          description: 'What have you eaten today?',
          category: 'nutrition',
        ),
      );
    }

    // Check for missing mood data
    final moodData = healthMetrics.userInputData.moodData;
    final bool hasMoodToday =
        moodData != null && moodData.timestamp.day == now.day;

    if (!hasMoodToday) {
      suggestions.add(
        HealthSuggestion(
          icon: Icons.mood,
          label: 'How are you feeling?',
          description: 'Track your mood today',
          category: 'mood',
        ),
      );
    }

    // Check for missing activity data
    final activityData = healthMetrics.autoDetectedData.activityData;
    final bool hasActivityToday =
        activityData != null && activityData.date.day == now.day;

    if (!hasActivityToday) {
      suggestions.add(
        HealthSuggestion(
          icon: Icons.directions_run,
          label: 'Track your activity',
          description: 'Record your steps and workouts',
          category: 'activity',
        ),
      );
    }

    // Always suggest checking air quality (미세먼지)
    suggestions.add(
      HealthSuggestion(
        icon: Icons.air,
        label: '미세먼지 (Air quality)',
        description: 'Check today\'s air quality',
        category: 'environmental',
      ),
    );

    // Always suggest checking weather impact on health
    suggestions.add(
      HealthSuggestion(
        icon: Icons.wb_sunny,
        label: 'Weather impact',
        description: 'How weather affects your health',
        category: 'environmental',
      ),
    );

    return suggestions;
  }
}

// Health provider
final healthProvider =
    StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  return HealthNotifier(repository);
});

// Health suggestion class for the UI
class HealthSuggestion {
  final IconData icon;
  final String label;
  final String description;
  final String category;

  HealthSuggestion({
    required this.icon,
    required this.label,
    required this.description,
    required this.category,
  });
}
