import 'dart:io';
import 'package:ate_project/features/auth/view_models/login_view_model.dart';
import 'package:ate_project/features/auth/views/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ate_project/core/widgets/loading_view.dart';
import 'package:ate_project/core/widgets/error_snackbar.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  late final LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ref.read(loginViewModelProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(loginViewModelProvider);
    final authState = ref.watch(authProvider);

    final isAuthLoading = authState.isLoading;
    final isLoading = viewState.isLoading;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (isAuthLoading || isLoading) {
        try {
          LoadingScreen.show(context, message: 'Signing in...');
        } catch (e) {
          print('Error showing loading screen: $e');
        }
      } else {
        try {
          LoadingScreen.dismiss(context);
        } catch (e) {
          print('Error dismissing loading screen: $e');
        }
      }

      // Check for errors from either authState or viewState
      final error = viewState.error;
      print('Error: $error');
      if (error != null && !isLoading && !isAuthLoading) {
        LoadingScreen.dismiss(context);

        ErrorSnackbar.showLoginError(
          context: context,
          errorMessage: error,
          clearError: () {
            viewModel.clearError();
          },
          onTryAgain: () {
            if (viewState.currentStep == LoginStep.emailInput) {
              viewModel.checkEmailAndContinue();
            } else {
              viewModel.handlePasswordLogin();
            }
          },
          onResetPassword: () {
            // TODO: Implement reset password flow
          },
          onCreateAccount: () {
            viewModel.redirectToSignup(context);
          },
        );
      }
    });

    final bool isAndroid = Platform.isAndroid;
    final bool isIOS = Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
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
                                      try {
                                        switch (viewState.currentStep) {
                                          case LoginStep.emailInput:
                                            final emailExists = await viewModel
                                                .checkEmailAndContinue();
                                            if (!emailExists &&
                                                context.mounted) {
                                              // Show dialog asking if they want to sign up
                                              _showSignupDialog(
                                                  context, viewModel);
                                            }
                                            break;

                                          case LoginStep.passwordInput:
                                            await viewModel
                                                .handlePasswordLogin();
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

                // Continue without login option
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: TextButton(
                        onPressed: () {
                          // Show a Cupertino dialog explaining limited features
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Continue as Guest'),
                              content: const Text(
                                  'You can use our app with limited features without signing in. Some personalized features will not be available.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: const Text('Continue'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.go(RouteNames.home);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Continue without signing in',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
    final viewModel = ref.read(loginViewModelProvider.notifier);

    try {
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
            await supabase.auth.signOut();
            context.push(RouteNames.signup);
          }
        } catch (e) {
          print("Error checking profile: $e");
          await supabase.auth.signOut();

          if (context.mounted) {
            LoadingScreen.dismiss(context);
            context.push(RouteNames.signup);
          }
        }
      }
    } catch (e) {
      print("Social login error: $e");
      if (context.mounted) {
        LoadingScreen.dismiss(context);

        ErrorSnackbar.showLoginError(
          context: context,
          errorMessage: e.toString(),
          clearError: () {
            viewModel.clearError();
          },
          onTryAgain: () {
            signInMethod();
          },
        );
      }
    }
  }
}
