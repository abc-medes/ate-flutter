import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/services/auth_service.dart';

enum SignupMethod {
  email,
  google,
  apple,
}

enum SignupStep {
  detailsInput,
  otpVerification,
  emailSent,
}

class SignupState {
  final String email;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController otpController;
  final bool isLoading;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? error; // system/network/supabase errors -> popup
  final String? plainError; // input/validation errors -> inline
  final bool isPasswordValid;
  final bool doPasswordsMatch;
  final SignupStep currentStep;
  final bool isVerificationSent;
  final bool isEmailValid;

  SignupState({
    required this.email,
    required this.emailController,
    required this.nameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.otpController,
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.error,
    this.plainError,
    this.isPasswordValid = true,
    this.doPasswordsMatch = true,
    this.currentStep = SignupStep.detailsInput,
    this.isVerificationSent = false,
    this.isEmailValid = true,
  });

  SignupState copyWith({
    String? email,
    TextEditingController? emailController,
    TextEditingController? nameController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    TextEditingController? otpController,
    bool? isLoading,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    String? error,
    String? plainError,
    bool clearError = false,
    bool clearPlainError = false,
    bool? isPasswordValid,
    bool? doPasswordsMatch,
    SignupStep? currentStep,
    bool? isVerificationSent,
    bool? isEmailValid,
  }) {
    return SignupState(
      email: email ?? this.email,
      emailController: emailController ?? this.emailController,
      nameController: nameController ?? this.nameController,
      passwordController: passwordController ?? this.passwordController,
      confirmPasswordController:
          confirmPasswordController ?? this.confirmPasswordController,
      otpController: otpController ?? this.otpController,
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      error: clearError ? null : error ?? this.error,
      plainError: clearPlainError ? null : plainError ?? this.plainError,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      doPasswordsMatch: doPasswordsMatch ?? this.doPasswordsMatch,
      currentStep: currentStep ?? this.currentStep,
      isVerificationSent: isVerificationSent ?? this.isVerificationSent,
      isEmailValid: isEmailValid ?? this.isEmailValid,
    );
  }

  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    emailController.dispose();
  }

  // Check if all required fields are filled for the current step
  bool get isFormValid {
    if (currentStep == SignupStep.detailsInput) {
      return nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          isEmailValid &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          isPasswordValid &&
          doPasswordsMatch;
    }
    return false;
  }
}

class SignupViewModel extends StateNotifier<SignupState> {
  final SupabaseClient _client = Supabase.instance.client;
  final AuthService _authService;
  bool _isDisposed = false;

  SignupViewModel(this._authService, String email)
      : super(SignupState(
          email: email,
          emailController: TextEditingController(text: email),
          nameController: TextEditingController(),
          passwordController: TextEditingController(),
          confirmPasswordController: TextEditingController(),
          otpController: TextEditingController(),
        )) {
    // DEV DEFAULTS: prefill signup form for development.
    assert(() {
      state.emailController.text = 'baikjyo@naver.com';
      state.nameController.text = 'aaa';
      state.passwordController.text = '12341234a';
      state.confirmPasswordController.text = '12341234a';
      validateEmail();
      validatePassword();
      validatePasswordsMatch();
      return true;
    }());
  }

  @override
  void dispose() {
    _isDisposed = true;
    state.emailController.dispose();
    state.nameController.dispose();
    state.passwordController.dispose();
    state.confirmPasswordController.dispose();
    state.otpController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    if (_isDisposed) return;
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    if (_isDisposed) return;
    state = state.copyWith(
        isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  void clearError() {
    if (_isDisposed) return;
    state = state.copyWith(clearError: true);
  }

  bool validateEmail() {
    if (_isDisposed) return false;
    final email = state.emailController.text.trim();
    final isValid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    state = state.copyWith(isEmailValid: isValid);
    return isValid;
  }

  bool validatePassword() {
    if (_isDisposed) return false;
    final password = state.passwordController.text;
    final isValid = password.length >= 8 && RegExp(r'\d').hasMatch(password);

    state = state.copyWith(isPasswordValid: isValid);
    return isValid;
  }

  bool validatePasswordsMatch() {
    if (_isDisposed) return false;
    final doMatch =
        state.passwordController.text == state.confirmPasswordController.text;

    state = state.copyWith(doPasswordsMatch: doMatch);
    return doMatch;
  }

  void goBackToDetails() {
    if (_isDisposed) return;
    state = state.copyWith(currentStep: SignupStep.detailsInput);
  }

  Future<void> signUp() async {
    if (_isDisposed) return;

    if (!validateEmail()) {
      state = state.copyWith(plainError: "Please enter a valid email address");
      return;
    }
    if (!validatePassword() || !validatePasswordsMatch()) {
      state = state.copyWith(
          plainError:
              "Please correct the errors in the form before continuing");
      return;
    }
    if (!state.isFormValid) {
      state = state.copyWith(
          plainError: "Please fill in all required fields correctly");
      return;
    }

    state = state.copyWith(
        isLoading: true, clearError: true, clearPlainError: true);

    try {
      if (_isDisposed) return;

      print(
          '[Signup] start email=${state.emailController.text} name=${state.nameController.text}');
      final res = await _authService.signUpWithEmail(
          email: state.emailController.text,
          password: state.passwordController.text,
          name: state.nameController.text);

      if (res.user == null) {
        print('[Signup] failed: user is null');
        state =
            state.copyWith(isLoading: false, error: "Failed to create user");
        return;
      }

      final bool userAlreadyExists = res.user?.identities?.isEmpty ?? false;
      final uid = res.user?.id;
      final confirmedAt = res.user?.emailConfirmedAt;
      final identities = res.user?.identities?.length ?? 0;
      print(
          '[Signup] response userId=$uid confirmedAt=$confirmedAt identities=$identities sessionPresent=${res.session != null}');

      if (userAlreadyExists) {
        print(
            '[Signup] user already exists for email=${state.emailController.text}');
        state =
            state.copyWith(isLoading: false, error: "User already registered");
        return;
      }

      state = state.copyWith(
        isLoading: false,
        currentStep: SignupStep.emailSent,
      );
      print('[Signup] email verification sent; moving to emailSent step');
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      print('[Signup] auth exception: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('[Signup] unexpected error: $e');
    }
  }

  Future<void> resendVerificationEmail() async {
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.resendSignupVerification(state.emailController.text);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> handleLogin(
      BuildContext context, SignupMethod signupMethod) async {
    if (!context.mounted) return;
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (signupMethod == SignupMethod.email) {
        await _authService.signInWithEmail(
            email: state.emailController.text,
            password: state.passwordController.text);
      } else if (signupMethod == SignupMethod.google) {
        await _authService.signInWithGoogle();
      } else if (signupMethod == SignupMethod.apple) {
        await _authService.signInWithApple();
      }

      await _client.auth.onAuthStateChange.firstWhere((e) => e.session != null);

      await wrapUpSignUp(context);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> wrapUpSignUp(BuildContext context) async {
    if (!context.mounted) return;
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true);

    try {
      await _authService.createProfile(
        userId: _authService.currentUser!.id,
        email: state.emailController.text,
        name: state.nameController.text,
      );
      await _authService
          .createEmptyUserHealthMetrics(_authService.currentUser!.id);

      state = state.copyWith(isLoading: false);

      if (context.mounted) context.go(RouteNames.onboarding);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } on PostgrestException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final signupViewModelProvider = StateNotifierProvider.family
    .autoDispose<SignupViewModel, SignupState, String>(
  (ref, email) {
    final authService = ref.watch(authServiceProvider);
    return SignupViewModel(authService, email);
  },
);
