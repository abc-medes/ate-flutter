import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/utils/auth_error_helper.dart';

enum LoginStep {
  emailInput,
  passwordInput,
}

class LoginState {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isEmailValid;
  final LoginStep currentStep;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? error;
  final bool showEmailOption;

  LoginState({
    required this.emailController,
    required this.passwordController,
    this.isEmailValid = true,
    this.currentStep = LoginStep.emailInput,
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.error,
    this.showEmailOption = false,
  });

  LoginState copyWith({
    TextEditingController? emailController,
    TextEditingController? passwordController,
    bool? isEmailValid,
    LoginStep? currentStep,
    bool? isPasswordVisible,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? showEmailOption,
  }) {
    return LoginState(
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      currentStep: currentStep ?? this.currentStep,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      showEmailOption: showEmailOption ?? this.showEmailOption,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthService _authService;
  final AuthNotifier _authNotifier;
  bool _isDisposed = false;

  LoginViewModel(this._authService, this._authNotifier)
      : super(LoginState(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
        ));

  @override
  void dispose() {
    _isDisposed = true;
    state.emailController.dispose();
    state.passwordController.dispose();
    super.dispose();
  }

  void setError(String errorMessage) {
    if (_isDisposed) return;
    state = state.copyWith(error: errorMessage);
  }

  bool validateEmail() {
    if (_isDisposed) return false;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isValid = state.emailController.text.isEmpty ||
        emailRegex.hasMatch(state.emailController.text);

    if (state.isEmailValid != isValid) {
      state = state.copyWith(isEmailValid: isValid);
    }
    return isValid;
  }

  void onEmailChanged() {
    if (_isDisposed) return;

    validateEmail();

    // Reset to email step if email changes
    if (state.currentStep != LoginStep.emailInput) {
      state = state.copyWith(
        currentStep: LoginStep.emailInput,
        passwordController: TextEditingController(),
      );
    }
  }

  void togglePasswordVisibility() {
    if (_isDisposed) return;
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void clearError() {
    if (_isDisposed) return;
    state = state.copyWith(clearError: true);
    _authNotifier.clearError();
  }

  Future<bool> checkEmailAndContinue() async {
    if (_isDisposed || state.isLoading) return false;

    if (!validateEmail()) {
      state =
          state.copyWith(error: "Please enter a valid email", isLoading: false);
      return false;
    }

    final email = state.emailController.text.trim();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Check if email exists
      final emailExists = await _authService.isEmailAvailable(email);

      if (_isDisposed) return false;

      state = state.copyWith(
        isLoading: false,
        currentStep: LoginStep.passwordInput,
      );

      return emailExists;
    } catch (e) {
      if (_isDisposed) return false;

      state = state.copyWith(
        isLoading: false,
        error: AuthErrorHelper.getLoginErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<void> handlePasswordLogin() async {
    if (_isDisposed || state.isLoading) return;

    final email = state.emailController.text.trim();
    final password = state.passwordController.text.trim();

    if (password.isEmpty) {
      state =
          state.copyWith(error: "Please enter your password", isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authService.signIn(email, password);
      if (_isDisposed) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (_isDisposed) return;
      state = state.copyWith(
        isLoading: false,
        error: AuthErrorHelper.getLoginErrorMessage(e.toString()),
      );
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {
      await _authNotifier.signInWithGoogle();
    } catch (e) {
      // Error is handled in AuthNotifier
    }
  }

  Future<void> handleAppleSignIn() async {
    try {
      await _authNotifier.signInWithApple();
    } catch (e) {
      // Error is handled in AuthNotifier
    }
  }

  void redirectToSignup(BuildContext context) {
    context.push(RouteNames.signup, extra: state.emailController.text);
  }

  void toggleEmailOption() {
    if (_isDisposed) return;
    state = state.copyWith(showEmailOption: true);
  }
}

final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final authNotifier = ref.watch(authProvider.notifier);
  return LoginViewModel(authService, authNotifier);
});
