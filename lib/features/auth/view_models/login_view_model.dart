import 'package:bodiapp/common_libs.dart';
import 'package:bodiapp/core/services/auth_service.dart';
import 'package:bodiapp/core/routes/route_names.dart';

enum LoginStep {
  emailInput,
  resettingEmailSent,
}

class LoginState {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isEmailValid;
  LoginStep currentStep;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? error;

  LoginState({
    required this.emailController,
    required this.passwordController,
    this.isEmailValid = true,
    this.currentStep = LoginStep.emailInput,
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.error,
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
  }) {
    return LoginState(
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      currentStep: currentStep ?? this.currentStep,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthService _authService;
  bool _isDisposed = false;

  LoginViewModel(this._authService)
      : super(LoginState(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
        ));

  @override
  void dispose() {
    _isDisposed = true;
    reset();
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
  }

  Future<void> handlePasswordLogin(BuildContext context) async {
    if (_isDisposed || state.isLoading) return;
    try {
      final email = state.emailController.text.trim();
      final password = state.passwordController.text.trim();

      if (password.isEmpty) {
        throw AuthException("Please enter your password");
      }

      state = state.copyWith(isLoading: true, clearError: true);
      await _authService.signInWithEmail(email: email, password: password);

      state = state.copyWith(isLoading: false);

      if (context.mounted) context.go(RouteNames.home);
    } catch (e) {
      if (e is AuthException) {
        state = state.copyWith(
          isLoading: false,
          error: e.message,
        );
      }
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {} catch (e) {
      // Error is handled in AuthNotifier
    }
  }

  Future<void> handleAppleSignIn() async {
    try {} catch (e) {
      // Error is handled in AuthNotifier
    }
  }

  void redirectToSignup(BuildContext context) {
    context.push(RouteNames.signup, extra: state.emailController.text);
  }

  void handleForgotPassword(BuildContext context) async {
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true);
    try {
      await _authService.resetPassword(
        state.emailController.text,
      );
      state = state.copyWith(
        currentStep: LoginStep.resettingEmailSent,
        isLoading: false,
      );
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void reset() {
    state.emailController.dispose();
    state.passwordController.dispose();
    state.currentStep = LoginStep.emailInput;
  }
}

final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginViewModel(authService);
});
