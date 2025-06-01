import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/features/auth/view_models/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/widgets/loading_view.dart';
import 'package:ate_project/core/widgets/error_snackbar.dart';
import 'package:ate_project/core/widgets/customed_text_input.dart';

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
      if (!mounted) return;

      if (viewState.error != null) {
        try {
          LoadingScreen.dismiss(context);
        } catch (e) {
          print('Error dismissing loading screen on error: $e');
        }

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
            Navigator.pop(context);
          },
        ),
        title: const Text('Log In'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CustomedTextInput(
                      controller: viewState.emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => viewModel.onEmailChanged(),
                      enabled: !viewState.isLoading,
                      errorText: !viewState.isEmailValid
                          ? 'Please enter a valid email'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    CustomedTextInput(
                      controller: viewState.passwordController,
                      hintText: 'Password',
                      obscureText: !viewState.isPasswordVisible,
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

                    const SizedBox(height: 16),

                    // Forgot password link
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
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: viewState.isLoading
                      ? null
                      : () async {
                          try {
                            await viewModel.handlePasswordLogin();
                          } catch (e) {
                            print("Login error: $e");
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
                    'Login',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
