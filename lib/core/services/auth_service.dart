import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isOnboardingCompleted;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;
  final String? email;

  AuthState({
    this.isAuthenticated = false,
    this.isOnboardingCompleted = false,
    this.isLoading = false,
    this.errorMessage,
    this.userId,
    this.email,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isOnboardingCompleted,
    bool? isLoading,
    String? errorMessage,
    String? userId,
    String? email,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> login({required String userId, required String email}) async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        isAuthenticated: true,
        userId: userId,
        email: email,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: "Login failed. Please try again.");
    }
  }

  void logout() {
    state = AuthState();
  }

  void completeOnboarding() {
    state = state.copyWith(isOnboardingCompleted: true);
  }

  void resetError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
