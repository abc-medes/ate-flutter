import 'dart:io';
import 'package:ate_project/features/auth/view_models/login_view_model.dart';
import 'package:ate_project/features/auth/views/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ate_project/core/widgets/loading_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  bool _previousLoadingState = false;

  @override
  void dispose() {
    // Make sure loading screen is dismissed when view is unmounted
    LoadingScreen.dismiss(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(loginViewModelProvider.notifier);
    final viewState = ref.watch(loginViewModelProvider);
    final authState = ref.watch(authProvider);

    // Check if loading from either auth state or local view state
    final isAuthLoading = authState.isLoading;
    final isLoading = viewState.isLoading;

    // Handle loading state changes after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previousLoadingState != isAuthLoading) {
        _previousLoadingState = isAuthLoading;
        if (isAuthLoading) {
          LoadingScreen.show(context, message: 'Signing in...');
        } else {
          LoadingScreen.dismiss(context);
        }
      }
    });

    // Get error message from either auth state or local view state
    final error = authState.errorMessage ?? viewState.error;

    // Check platform
    final bool isAndroid = Platform.isAndroid;
    final bool isIOS = Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: viewState.currentStep == LoginStep.passwordInput
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (viewState.currentStep == LoginStep.passwordInput) {
                    // If in password step, go back to email step
                    viewModel.onEmailChanged();
                  }
                },
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Social login buttons - Now at the top
                SocialAuthButton(
                  ref: ref,
                  text: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: AppColors.textPrimary,
                  onPressed: () {
                    if (!isLoading) {
                      _handleSocialLogin(
                          context, ref, viewModel.handleGoogleSignIn);
                    }
                  },
                ),

                if (isIOS || !isAndroid) ...[
                  const SizedBox(height: 12),
                  SocialAuthButton(
                    ref: ref,
                    text: 'Continue with Apple',
                    icon: Icons.apple,
                    iconColor: AppColors.textPrimary,
                    onPressed: () {
                      if (!isLoading) {
                        _handleSocialLogin(
                            context, ref, viewModel.handleAppleSignIn);
                      }
                    },
                  ),
                ],

                const SizedBox(height: 32),

                // Or divider
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: AppColors.textTertiary.withAlpha(128))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: AppColors.textTertiary.withAlpha(128))),
                  ],
                ),
                const SizedBox(height: 24),

                // Email login section - conditionally shown
                viewState.currentStep == LoginStep.passwordInput ||
                        viewState.showEmailOption
                    ? Column(
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
                                hintStyle:
                                    TextStyle(color: AppColors.textTertiary),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: InputBorder.none,
                                errorStyle:
                                    const TextStyle(height: 0, fontSize: 0),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) => viewModel.onEmailChanged(),
                              enabled: !isLoading,
                            ),
                          ),

                          if (!viewState.isEmailValid)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 4.0),
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
                                  hintStyle:
                                      TextStyle(color: AppColors.textTertiary),
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
                                    onPressed:
                                        viewModel.togglePasswordVisibility,
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
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      switch (viewState.currentStep) {
                                        case LoginStep.emailInput:
                                          final emailExists = await viewModel
                                              .checkEmailAndContinue();
                                          if (!emailExists && context.mounted) {
                                            // Show dialog asking if they want to sign up
                                            _showSignupDialog(
                                                context, viewModel);
                                          }
                                          break;

                                        case LoginStep.passwordInput:
                                          await viewModel.handlePasswordLogin();
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
                                  onTap: () {
                                    // TODO: Implement forgot password flow
                                  },
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
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => viewModel.toggleEmailOption(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AppColors.textTertiary.withAlpha(128)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Sign in with Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 24),

                // Don't have an account - Sign up link - Show for both steps
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(RouteNames.signup,
                              extra: viewState.emailController.text.isNotEmpty
                                  ? viewState.emailController.text
                                  : null);
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error message if any
                if (error != null)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                error,
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                viewModel.clearError();
                              },
                              color: AppColors.error,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        if (error.toLowerCase().contains("failed") ||
                            error.toLowerCase().contains("invalid")) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  viewModel.redirectToSignup(context);
                                },
                                child: Text(
                                  'Create a new account instead',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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

  void _handleSocialLogin(BuildContext context, WidgetRef ref,
      Future<void> Function() signInMethod) async {
    final supabase = Supabase.instance.client;

    await signInMethod();

    // Check if user profile exists after successful auth
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response == null && context.mounted) {
          // Profile doesn't exist, redirect to signup
          await supabase.auth.signOut();
          context.push(RouteNames.signup);
        }
      } catch (e) {
        // Error checking profile, assume it doesn't exist
        await supabase.auth.signOut();
        if (context.mounted) {
          context.push(RouteNames.signup);
        }
      }
    }
  }
}
