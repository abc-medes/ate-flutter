import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/theme/app_theme.dart';
import 'package:ate_project/features/auth/view_models/signup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/widgets/loading_view.dart';
import 'package:ate_project/core/widgets/error_snackbar.dart';
import 'package:ate_project/core/widgets/customed_text_input.dart';

class SignupView extends ConsumerStatefulWidget {
  final String email;

  const SignupView({super.key, required this.email});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  late final SignupViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ref.read(signupViewModelProvider(widget.email).notifier);
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(signupViewModelProvider(widget.email));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isCurrentlyLoading = viewState.isLoading;

      if (isCurrentlyLoading) {
        LoadingScreen.show(context, message: 'Creating your account...');
      } else {
        LoadingScreen.dismiss(context);
      }

      if (viewState.error != null) {
        LoadingScreen.dismiss(context);

        ErrorSnackbar.showSignupError(
          context: context,
          errorMessage: viewState.error!,
          clearError: () => viewModel.clearError(),
          onTryAgain: () => viewModel.signUp(),
          onGoToLogin: () => context.go(RouteNames.login),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (viewState.currentStep == SignupStep.emailSent) {
              viewModel.goBackToDetails();
              /* Comment out OTP verification step
            } else if (viewState.currentStep == SignupStep.otpVerification) {
              viewModel.goBackToDetails();
            */
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (viewState.currentStep == SignupStep.detailsInput)
                Expanded(
                    child: _buildDetailsStep(context, viewModel, viewState)),
              if (viewState.currentStep == SignupStep.emailSent)
                Expanded(
                    child: _buildEmailSentStep(context, viewModel, viewState)),
              // _buildEmailSentStep(context, viewModel, viewState),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: viewState.isLoading
                      ? null
                      : () async {
                          await viewModel.signUp();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: AppColors.surface,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsStep(
    BuildContext context,
    SignupViewModel viewModel,
    SignupState viewState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        CustomedTextInput(
          controller: viewState.emailController,
          hintText: 'Email',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => viewModel.validateEmail(),
          errorText: !viewState.isEmailValid
              ? 'Please enter a valid email address'
              : null,
        ),
        const SizedBox(height: 24),

        // Name field
        CustomedTextInput(
          controller: viewState.nameController,
          hintText: 'Full Name',
          isRequired: true,
        ),
        const SizedBox(height: 24),

        // Password field
        CustomedTextInput(
          controller: viewState.passwordController,
          hintText: 'Password',
          isRequired: true,
          obscureText: !viewState.isPasswordVisible,
          onChanged: (_) => viewModel.validatePassword(),
          errorText: !viewState.isPasswordValid
              ? 'Password must be at least 8 characters with at least 1 number'
              : null,
          suffixIcon: IconButton(
            icon: Icon(
              viewState.isPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.textTertiary,
            ),
            onPressed: viewModel.togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 24),

        // Confirm Password field
        CustomedTextInput(
          controller: viewState.confirmPasswordController,
          hintText: 'Confirm Password',
          isRequired: true,
          obscureText: !viewState.isConfirmPasswordVisible,
          onChanged: (_) => viewModel.validatePasswordsMatch(),
          errorText:
              !viewState.doPasswordsMatch ? 'Passwords do not match' : null,
          suffixIcon: IconButton(
            icon: Icon(
              viewState.isConfirmPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.textTertiary,
            ),
            onPressed: viewModel.toggleConfirmPasswordVisibility,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEmailSentStep(
    BuildContext context,
    SignupViewModel viewModel,
    SignupState viewState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent an email to ${viewState.emailController.text} with a verification link. Please click the link in your email to complete your registration.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),

        // Email icon
        Center(
          child: Icon(
            Icons.email_outlined,
            size: 80,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 32),

        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next steps:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. ', style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(
                    child: Text(
                      'Check your email inbox for a verification link from us',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('2. ', style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(
                    child: Text(
                      'Click on the link in the email to verify your account',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('3. ', style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(
                    child: Text(
                      'Return to the app to complete your registration',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Resend email button
        Center(
          child: TextButton(
            onPressed: viewState.isLoading
                ? null
                : () async {
                    // Skip email verification for now and proceed to sign up directly
                    await viewModel.signUp();
                  },
            child: Text(
              'Didn\'t receive the email? Resend',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: () {
              context.go(RouteNames.login);
            },
            child: Text(
              'Back to Login',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
