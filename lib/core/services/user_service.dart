import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ate_project/data/models/user_model.dart' as app_models;
import 'package:ate_project/core/services/auth_service.dart';

// User state model
class UserState {
  final app_models.User? user;
  final bool isLoading;
  final String? errorMessage;

  UserState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  UserState copyWith({
    app_models.User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isOnboardingCompleted =>
      user != null && user!.onboardingStatus.isCompleted;
}

// User service that handles user data
class UserService {
  final AuthService _authService;
  final SupabaseClient _client = Supabase.instance.client;

  UserService(this._authService);

  // Get current user data
  Future<app_models.User?> getCurrentUser() async {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) return null;

    final profileData = await fetchUserProfile(supabaseUser.id);
    return app_models.User.fromSupabase(supabaseUser, profileData);
  }

  // Stream of user data with profile
  Stream<app_models.User?> getUserStream() {
    return _authService.userIdStream.asyncMap((userId) async {
      if (userId == null) return null;

      try {
        final profileData = await fetchUserProfile(userId);
        final supabaseUser = _client.auth.currentUser;
        if (supabaseUser == null) return null;

        return app_models.User.fromSupabase(supabaseUser, profileData);
      } catch (e) {
        print('Error fetching user data: $e');
        return null;
      }
    });
  }

  // Fetch user profile from the database
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', userId).single();

      return response ?? {};
    } catch (e) {
      // If no profile exists, return empty map
      return {};
    }
  }

  // Update user profile
  Future<app_models.User?> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _client.from('profiles').update(data).eq('id', userId);

      // Fetch updated profile
      return await getCurrentUser();
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Update health profile
  Future<app_models.User?> updateHealthProfile(
      String userId, app_models.HealthProfile healthProfile) async {
    try {
      final data = {
        'health_profile': healthProfile.toJson(),
        'onboarding_status': {'health_profile_completed': true}
      };

      return await updateUserProfile(userId, data);
    } catch (e) {
      throw Exception('Failed to update health profile: ${e.toString()}');
    }
  }

  // Complete an onboarding step
  Future<app_models.User?> completeOnboardingStep(
      String userId, String step) async {
    try {
      final profileData = await fetchUserProfile(userId);
      final onboardingStatus = app_models.OnboardingStatus.fromJson(
          profileData['onboarding_status'] ?? {});

      final updatedStatus = onboardingStatus.completeStep(step);

      // Check if all steps are completed
      if (updatedStatus.isCompleted) {
        final data = {
          'onboarding_status': {
            ...updatedStatus.toJson(),
            'completed_at': DateTime.now().toIso8601String()
          }
        };
        return await updateUserProfile(userId, data);
      } else {
        final data = {'onboarding_status': updatedStatus.toJson()};
        return await updateUserProfile(userId, data);
      }
    } catch (e) {
      throw Exception('Failed to complete onboarding step: ${e.toString()}');
    }
  }
}

// User notifier
class UserNotifier extends StateNotifier<UserState> {
  final UserService _userService;
  final String? userId;
  StreamSubscription<app_models.User?>? _userSubscription;

  UserNotifier(this._userService, this.userId) : super(UserState()) {
    if (userId != null) {
      _initializeUser();
    }
  }

  void _initializeUser() {
    state = UserState(isLoading: true);

    _userSubscription = _userService.getUserStream().listen(
      (user) {
        state = UserState(user: user, isLoading: false);
      },
      onError: (error) {
        state = UserState(
          errorMessage: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  Future<void> refreshUser() async {
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final user = await _userService.getCurrentUser();
      state = UserState(user: user, isLoading: false);
    } catch (e) {
      state = UserState(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateHealthProfile(
      app_models.HealthProfile healthProfile) async {
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final updatedUser = await _userService.updateHealthProfile(
        userId!,
        healthProfile,
      );
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> completeOnboardingStep(String step) async {
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final updatedUser = await _userService.completeOnboardingStep(
        userId!,
        step,
      );
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

// User provider that depends on auth state
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final userService = ref.watch(userServiceProvider);
  final userId = ref.watch(userIdProvider);

  return UserNotifier(userService, userId);
});

// Helper user providers
final currentUserProvider = Provider<app_models.User?>((ref) {
  return ref.watch(userProvider).user;
});

final isOnboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isOnboardingCompleted;
});

final userLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).errorMessage;
});
