import 'package:bodiapp/common_libs.dart';
import 'package:bodiapp/core/routes/route_names.dart';
import 'package:bodiapp/features/auth/view_models/signup_view_model.dart';
import 'package:bodiapp/features/auth/views/widgets/email_sent_step.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bodiapp/core/widgets/loading_view.dart';
import 'package:bodiapp/core/widgets/error_snackbar.dart';
import 'package:bodiapp/core/widgets/customed_text_input.dart';

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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          $strings.signUp,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (viewState.currentStep == SignupStep.detailsInput)
                        _buildDetailsStep(context, viewModel, viewState),
                      if (viewState.currentStep == SignupStep.emailSent)
                        EmailSentStep(
                          title: 'Verify Your Email',
                          description:
                              "We've sent an email to ${viewState.emailController.text} with a verification link. Please click the link in your email to complete your registration.",
                          nextStepsTitle: 'Next steps:',
                          nextSteps: [
                            'Check your email inbox for a verification link from us',
                            'Click on the link in the email to verify your account',
                            'Return to the app to complete your registration',
                          ],
                          resendButtonText: "Didn't receive the email? Resend",
                          onResend: viewState.isLoading
                              ? null
                              : () async {/* resend logic */},
                          backToLoginText: 'Back to Login',
                          onBackToLogin: () => context.go(RouteNames.login),
                          isLoading: viewState.isLoading,
                        ),
                      // _buildEmailSentStep(context, viewModel, viewState),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: viewState.isLoading
                      ? null
                      : () async {
                          switch (viewState.currentStep) {
                            case SignupStep.detailsInput:
                              await viewModel.signUp();
                              break;
                            case SignupStep.emailSent:
                              await viewModel.wrapUpEmailSignUp(context);
                              break;
                            default:
                              break;
                          }
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
    return SingleChildScrollView(
      child: Column(
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
      ),
    );
  }
}
