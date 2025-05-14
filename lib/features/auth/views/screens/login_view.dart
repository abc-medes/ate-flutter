import 'dart:io';
import 'package:ate_project/features/auth/view_models/login_view_model.dart';
import 'package:ate_project/features/auth/views/widgets/social_login_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.textSecondary,
              ),
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
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
            constraints: const BoxConstraints(minHeight: 400),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: AppColors.divider),
            ),
            child: Center(
              child: Column(
                children: [
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
                  if ((isIOS || !isAndroid)) ...[
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
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.push(RouteNames.emailLoginInput,
                                  extra:
                                      viewState.emailController.text.isNotEmpty
                                          ? viewState.emailController.text
                                          : null);
                            },
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
                ],
              ),
            ),
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
