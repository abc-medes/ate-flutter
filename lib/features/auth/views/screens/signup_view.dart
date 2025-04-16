import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/features/auth/view_models/signup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/widgets/loading_view.dart';

class SignupView extends ConsumerStatefulWidget {
  final String email;

  const SignupView({super.key, required this.email});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  bool _previousLoadingState = false;
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

      if (!isCurrentlyLoading && viewState.error != null) {
        LoadingScreen.dismiss(context);
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
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: () {
              switch (viewState.currentStep) {
                case SignupStep.detailsInput:
                  return _buildDetailsStep(context, viewModel, viewState);
                case SignupStep.emailSent:
                  return _buildEmailSentStep(context, viewModel, viewState);
                // default:
                //   return _buildDetailsStep(context, viewModel, viewState);
              }
            }(),
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
        const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account with the details below',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),

        // Email field
        _buildInputField(
          hintText: 'Email',
          controller: viewState.emailController,
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => viewModel.validateEmail(),
        ),

        // Email validation error
        if (!viewState.isEmailValid)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Please enter a valid email address',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 24),

        // Name field
        _buildInputField(
          hintText: 'Full Name',
          controller: viewState.nameController,
          isRequired: true,
        ),
        const SizedBox(height: 24),

        // Password field
        _buildPasswordField(
          hintText: 'Password',
          controller: viewState.passwordController,
          isVisible: viewState.isPasswordVisible,
          toggleVisibility: viewModel.togglePasswordVisibility,
          onChanged: (_) => viewModel.validatePassword(),
        ),

        // Password validation error
        if (!viewState.isPasswordValid)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Password must be at least 8 characters with at least 1 number',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 24),

        // Confirm Password field
        _buildPasswordField(
          hintText: 'Confirm Password',
          controller: viewState.confirmPasswordController,
          isVisible: viewState.isConfirmPasswordVisible,
          toggleVisibility: viewModel.toggleConfirmPasswordVisibility,
          onChanged: (_) => viewModel.validatePasswordsMatch(),
        ),

        // Password match error
        if (!viewState.doPasswordsMatch)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Passwords do not match',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 40),

        // Continue button
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
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Error message
        if (viewState.error != null) _buildErrorMessage(viewState, viewModel),
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

        // Back to login button
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

        // Error message
        if (viewState.error != null) _buildErrorMessage(viewState, viewModel),
      ],
    );
  }

  Widget _buildErrorMessage(SignupState viewState, SignupViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewState.error!,
              style: TextStyle(color: AppColors.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => viewModel.clearError(),
            color: AppColors.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Helper methods for UI components
  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: isRequired ? '$hintText *' : hintText,
          hintStyle: TextStyle(color: AppColors.textTertiary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: InputBorder.none,
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: '$hintText *',
          hintStyle: TextStyle(color: AppColors.textTertiary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textTertiary,
            ),
            onPressed: toggleVisibility,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
