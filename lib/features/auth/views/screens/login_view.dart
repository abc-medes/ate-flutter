import 'dart:io';
import 'package:bodai/common_libs.dart';
import 'package:bodai/core/services/user_service.dart';
import 'package:bodai/core/widgets/typewriter_animated_text.dart';
import 'package:bodai/features/_common/bodai_logo.dart';
import 'package:bodai/features/auth/view_models/login_view_model.dart';
import 'package:bodai/features/auth/views/widgets/social_login_button.dart';
import 'package:bodai/core/routes/route_names.dart';
import 'package:bodai/core/widgets/loading_view.dart';
import 'package:bodai/core/widgets/error_snackbar.dart';

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
  void dispose() {
    LoadingScreen.dismiss(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(loginViewModelProvider);

    final isLoading = viewState.isLoading;

    ref.listen<bool>(
      loginViewModelProvider.select((s) => s.isLoading),
      (prev, isLoading) {
        if (isLoading) {
          LoadingScreen.show(context, message: 'Signing in...');
        } else {
          LoadingScreen.dismiss(context);
        }
      },
    );

    if (viewState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final error = viewState.error;
        ErrorSnackbar.showLoginError(
          context: context,
          errorMessage: error!,
          clearError: () {
            viewModel.clearError();
          },
          onTryAgain: () {},
          onResetPassword: () {
            viewModel.handleForgotPassword(context);
          },
          onCreateAccount: () {
            viewModel.redirectToSignup(context);
          },
        );
        viewModel.clearError(); // Clear error immediately
      });
    }

    final bool isAndroid = Platform.isAndroid;
    final bool isIOS = Platform.isIOS;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: $styles.sizes.maxContentWidth1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BodaiLogo(size: $styles.sizes.maxContentWidth3 * 0.5),
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
                            style: TextStyle(color: $styles.colors.greyMedium),
                          ),
                          Gap($styles.insets.xs),
                          GestureDetector(
                            onTap: () {
                              context.push(RouteNames.signup,
                                  extra:
                                      viewState.emailController.text.isNotEmpty
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
    );
  }

  void _handleSocialLogin(BuildContext context, WidgetRef ref,
      Future<void> Function() signInMethod) async {
    final supabase = Supabase.instance.client;
    final viewModel = ref.read(loginViewModelProvider.notifier);
    final userService = ref.read(userServiceProvider);

    try {
      await signInMethod();

      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          final profile = await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (profile == null) {
            final email = user.email ?? '';
            final meta = user.userMetadata ?? {};
            final name = (meta['name'] ??
                    meta['full_name'] ??
                    meta['preferred_username'] ??
                    (email.isNotEmpty ? email.split('@').first : ''))
                .toString();

            await userService.createProfile(
              userId: user.id,
              email: email,
              name: name,
            );
            await userService.createEmptyUserHealthMetrics(user.id);

            if (context.mounted) context.go(RouteNames.onboarding);
          } else {
            if (context.mounted) context.go(RouteNames.home);
          }
        } catch (e) {
          print("Post-login handling error: $e");
          if (context.mounted) {
            LoadingScreen.dismiss(context);
            context.go(RouteNames.onboarding);
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
