import 'dart:io';
import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/widgets/typewriter_animated_text.dart';
import 'package:ate_project/features/_common/ins_logo.dart';
import 'package:ate_project/features/auth/view_models/login_view_model.dart';
import 'package:ate_project/features/auth/views/widgets/social_login_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/routes/route_names.dart';
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

    final isAuthLoading = false;
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

      final error = viewState.error;
      if (error != null && !isLoading && !isAuthLoading) {
        LoadingScreen.dismiss(context);

        ErrorSnackbar.showLoginError(
          context: context,
          errorMessage: error,
          clearError: () {
            viewModel.clearError();
          },
          onTryAgain: () {},
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
      body: ColoredBox(
        color: $styles.colors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: $styles.sizes.maxContentWidth1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InsLogo(size: $styles.sizes.maxContentWidth3 * 0.2),
                      Gap($styles.insets.xs),
                      TypewriterAnimatedText(
                        loop: false,
                        [
                          $strings.appIntroduce_1,
                          $strings.appIntroduce_2,
                          $strings.appIntroduce_3,
                        ],
                        textStyle: $styles.text.h2.copyWith(
                          color: $styles.colors.accent1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              textStyle: $styles.text.quote2Sub,
              // color: Color(0xFFF5E9C8),
              color: $styles.colors.backgroundDark,
              elevation: 2,
              borderRadius: BorderRadius.circular(36),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
                constraints: const BoxConstraints(minHeight: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      SocialAuthButton(
                        ref: ref,
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata_rounded,
                        iconColor: $styles.colors.black,
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
                          iconColor: $styles.colors.black,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              color: $styles.colors.greyMedium,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              $strings.or,
                              style: TextStyle(
                                height: 1,
                                color: $styles.colors.greyMedium,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: $styles.colors.greyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SocialAuthButton(
                        ref: ref,
                        text: $strings.signInWithEmail,
                        icon: null,
                        iconColor: $styles.colors.black,
                        onPressed: () {
                          context.push(RouteNames.emailLoginInput);
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              $strings.askingIsMember,
                              style:
                                  TextStyle(color: $styles.colors.greyMedium),
                            ),
                            Gap($styles.insets.xs),
                            GestureDetector(
                              onTap: () {
                                context.push(RouteNames.signup,
                                    extra: viewState
                                            .emailController.text.isNotEmpty
                                        ? viewState.emailController.text
                                        : null);
                              },
                              child: Text(
                                $strings.signUp,
                                style: TextStyle(
                                  color: $styles.colors.accent1,
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
            ),
          ],
        ),
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
