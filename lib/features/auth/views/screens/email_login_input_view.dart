import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/features/auth/view_models/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/widgets/loading_view.dart';
import 'package:ate_project/core/widgets/error_snackbar.dart';

class EmailLoginInputView extends ConsumerStatefulWidget {
  const EmailLoginInputView({super.key});

  @override
  ConsumerState<EmailLoginInputView> createState() =>
      _EmailLoginInputViewState();
}

class _EmailLoginInputViewState extends ConsumerState<EmailLoginInputView> {
  late final LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ref.read(loginViewModelProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(loginViewModelProvider);

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
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Email Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: viewState.emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => viewModel.onEmailChanged(),
                  enabled: !viewState.isLoading,
                ),
              ),

              if (!viewState.isEmailValid)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    'Please enter a valid email',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Password Input - Show when needed
              if (viewState.currentStep == LoginStep.passwordInput)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: viewState.passwordController,
                    obscureText: !viewState.isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      border: InputBorder.none,
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
                  ),
                ),

              const SizedBox(height: 16),

              // Continue/Login button for Email/Password
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: viewState.isLoading
                      ? null
                      : () async {
                          try {
                            switch (viewState.currentStep) {
                              case LoginStep.emailInput:
                                final emailExists =
                                    await viewModel.checkEmailAndContinue();
                                if (!emailExists && context.mounted) {
                                  // Show dialog asking if they want to sign up
                                  _showSignupDialog(context, viewModel);
                                }
                                break;

                              case LoginStep.passwordInput:
                                await viewModel.handlePasswordLogin();
                                break;
                            }

                            // Force dismiss loading screen
                            if (mounted) {
                              LoadingScreen.dismiss(context);
                            }
                          } catch (e) {
                            print("Login error: $e");
                            // Safety net to ensure loading is dismissed on any error
                            if (mounted) {
                              LoadingScreen.dismiss(context);
                            }
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
                    viewState.currentStep == LoginStep.emailInput
                        ? 'Continue'
                        : 'Login',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Forgot password link
              if (viewState.currentStep == LoginStep.passwordInput)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: AppColors.primary,
                        ),
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
}

void _showSignupDialog(BuildContext context, LoginViewModel viewModel) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Account Not Found'),
      content: const Text(
          'No account exists with this email. Would you like to create a new account?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            viewModel.redirectToSignup(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Sign Up'),
        ),
      ],
    ),
  );
}
