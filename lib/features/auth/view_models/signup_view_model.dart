import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/core/services/user_service.dart';

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
  final String? error;
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
    bool clearError = false,
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
  final AuthService _authService;
  final UserService _userService;
  bool _isDisposed = false;

  SignupViewModel(this._authService, this._userService, String email)
      : super(SignupState(
          email: email,
          emailController: TextEditingController(text: email),
          nameController: TextEditingController(),
          passwordController: TextEditingController(),
          confirmPasswordController: TextEditingController(),
          otpController: TextEditingController(),
        ));

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
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    final isValid = emailRegex.hasMatch(state.emailController.text);
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
      throw AuthException("Please enter a valid email address");
    }

    if (!validatePassword() || !validatePasswordsMatch()) {
      throw AuthException(
          "Please correct the errors in the form before continuing");
    }

    if (!state.isFormValid) {
      throw AuthException("Please fill in all required fields correctly");
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (_isDisposed) return;

      final res = await _authService.signUpWithEmail(
          email: state.emailController.text,
          password: state.passwordController.text,
          name: state.nameController.text);

      if (res.user == null) {
        throw AuthException('User not found');
      }

      final bool userAlreadyExists = res.user?.identities?.isEmpty ?? false;

      if (userAlreadyExists) {
        throw AuthException('User already registered');
      }

      state = state.copyWith(
        isLoading: false,
        currentStep: SignupStep.emailSent,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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

  Future<void> wrapUpEmailSignUp(BuildContext context) async {
    if (!context.mounted) return;
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true);

    try {
      final res = await _authService.signInWithEmail(
          email: state.emailController.text,
          password: state.passwordController.text);

      await _userService.createProfile(
          userId: res.user?.id ?? '',
          email: state.emailController.text,
          name: state.nameController.text);

      await _userService.createEmptyUserHealthMetrics(res.user!.id);

      state = state.copyWith(isLoading: false);

      if (context.mounted) context.go(RouteNames.home);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
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
    final userService = ref.watch(userServiceProvider);
    return SignupViewModel(authService, userService, email);
  },
);
