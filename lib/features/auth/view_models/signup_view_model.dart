import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/services/auth_service.dart';

enum SignupStep {
  detailsInput,
  // otpVerification, // Commented out - will be re-enabled later
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

  SignupViewModel(this._authService, String email)
      : super(SignupState(
          email: email,
          emailController: TextEditingController(text: email),
          nameController: TextEditingController(),
          passwordController: TextEditingController(),
          confirmPasswordController: TextEditingController(),
          otpController: TextEditingController(),
        ));

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
        isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  bool validateEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isValid = emailRegex.hasMatch(state.emailController.text);
    state = state.copyWith(isEmailValid: isValid);
    return isValid;
  }

  bool validatePassword() {
    // Password should be at least 8 characters and contain at least one number
    final password = state.passwordController.text;
    final isValid = password.length >= 8 && RegExp(r'\d').hasMatch(password);

    state = state.copyWith(isPasswordValid: isValid);
    return isValid;
  }

  bool validatePasswordsMatch() {
    final doMatch =
        state.passwordController.text == state.confirmPasswordController.text;

    state = state.copyWith(doPasswordsMatch: doMatch);
    return doMatch;
  }

  void goBackToDetails() {
    state = state.copyWith(currentStep: SignupStep.detailsInput);
  }

  // Direct signup method without email verification
  Future<bool> signUp() async {
    if (!validateEmail()) {
      state = state.copyWith(
          error: "Please enter a valid email address", isLoading: false);
      return false;
    }

    if (!validatePassword() || !validatePasswordsMatch()) {
      state = state.copyWith(
          error: "Please correct the errors in the form before continuing",
          isLoading: false);
      return false;
    }

    if (!state.isFormValid) {
      state = state.copyWith(
          error: "Please fill in all required fields correctly",
          isLoading: false);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authService.signUp(state.emailController.text,
          state.passwordController.text, state.nameController.text);

      state = state.copyWith(
        isLoading: false,
        currentStep: SignupStep.emailSent, // Show success screen
      );

      return true;
    } catch (e) {
      print('SIGNUP ERROR: $e');
      state = state.copyWith(
        isLoading: false, // Make sure loading is set to false on error
        error: "Failed to sign up: ${e.toString()}",
      );
      return false;
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
