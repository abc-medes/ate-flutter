import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/routes/route_names.dart';

class LoginState {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isEmailValid;
  final bool showPassword;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? error;

  LoginState({
    required this.emailController,
    required this.passwordController,
    this.isEmailValid = true,
    this.showPassword = false,
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.error,
  });

  LoginState copyWith({
    TextEditingController? emailController,
    TextEditingController? passwordController,
    bool? isEmailValid,
    bool? showPassword,
    bool? isPasswordVisible,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LoginState(
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      showPassword: showPassword ?? this.showPassword,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthService _authService;
  final AuthNotifier _authNotifier;
  final SupabaseClient _supabase = Supabase.instance.client;

  LoginViewModel(this._authService, this._authNotifier)
      : super(LoginState(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
        ));

  bool validateEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isValid = state.emailController.text.isEmpty ||
        emailRegex.hasMatch(state.emailController.text);

    if (state.isEmailValid != isValid) {
      state = state.copyWith(isEmailValid: isValid);
    }
    return isValid;
  }

  void onEmailChanged() {
    validateEmail();

    // Reset password field if email changes when password is showing
    if (state.showPassword) {
      state = state.copyWith(showPassword: false);
    }
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
    _authNotifier.clearError();
  }

  Future<bool> checkEmailExists(BuildContext context) async {
    if (!validateEmail() || state.emailController.text.isEmpty) {
      state = state.copyWith(isEmailValid: false);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isEmailAvailable =
          await _authService.isEmailAvailable(state.emailController.text);

      state = state.copyWith(isLoading: false);

      if (isEmailAvailable) {
        // Email doesn't exist - should go to signup
        return false;
      } else {
        // Email exists - show password field
        state = state.copyWith(showPassword: true);
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Error checking email: ${e.toString()}",
      );
      return false;
    }
  }

  Future<bool> handlePasswordLogin() async {
    if (state.passwordController.text.isEmpty) {
      state = state.copyWith(error: "Please enter your password");
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _supabase.auth.signInWithPassword(
        email: state.emailController.text,
        password: state.passwordController.text,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Login failed: ${e.toString()}",
      );
      return false;
    }
  }

  void checkUserProfileExists(
      User? user, Function(bool exists) onComplete) async {
    if (user == null) {
      onComplete(false);
      return;
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      onComplete(response != null);
    } catch (e) {
      onComplete(false);
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {
      await _authNotifier.signInWithGoogle();

      // Auth state will be updated by the stream listener
    } catch (e) {
      // Error is handled in AuthNotifier
    }
  }

  Future<void> handleAppleSignIn() async {
    try {
      await _authNotifier.signInWithApple();

      // Auth state will be updated by the stream listener
    } catch (e) {
      // Error is handled in AuthNotifier
    }
  }
}

final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final authNotifier = ref.watch(authProvider.notifier);
  return LoginViewModel(authService, authNotifier);
});
