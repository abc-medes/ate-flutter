import 'dart:io';

import 'package:bodai/common_libs.dart';
import 'package:bodai/core/routes/route_names.dart';
import 'package:bodai/core/services/auth_service.dart';
import 'package:bodai/core/utils/social_auth_flow_utils.dart';
import 'package:bodai/core/widgets/page_header.dart';
import 'package:bodai/features/auth/view_models/login_view_model.dart';
import 'package:bodai/features/auth/view_models/signup_view_model.dart';
import 'package:bodai/features/auth/views/widgets/email_sent_step.dart';
import 'package:bodai/features/auth/views/widgets/social_login_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bodai/core/widgets/loading_view.dart';
import 'package:bodai/core/widgets/error_snackbar.dart';
import 'package:bodai/core/widgets/customed_text_input.dart';

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
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          const PageHeader(title: 'Sign Up'),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all($styles.insets.md),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (viewState.currentStep ==
                                SignupStep.detailsInput)
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
                                resendButtonText:
                                    "Didn't receive the email? Resend",
                                onResend: viewState.isLoading
                                    ? null
                                    : () async {/* resend logic */},
                                backToLoginText: 'Back to Login',
                                onBackToLogin: () =>
                                    context.go(RouteNames.login),
                                isLoading: viewState.isLoading,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: $styles.insets.xl,
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
                          backgroundColor: $styles.colors.accent1,
                          foregroundColor: $styles.colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular($styles.corners.md),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: $styles.text.bodyBold.copyWith(
                            color: $styles.colors.white,
                          ),
                        ),
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

  Widget _buildDetailsStep(
    BuildContext context,
    SignupViewModel viewModel,
    SignupState viewState,
  ) {
    final bool isAndroid = Platform.isAndroid;
    final bool isIOS = Platform.isIOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomedTextInput(
          controller: viewState.emailController,
          hintText: 'Email',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => viewModel.validateEmail(),
          errorText: !viewState.isEmailValid
              ? 'Please enter a valid email address'
              : null,
          textStyle: $styles.text.bodySmall,
          hintTextStyle:
              $styles.text.bodySmall.copyWith(color: $styles.colors.greyMedium),
          contentPadding: EdgeInsets.symmetric(
            horizontal: $styles.insets.sm,
            vertical: $styles.insets.sm,
          ),
        ),
        SizedBox(height: $styles.insets.sm),
        CustomedTextInput(
          controller: viewState.nameController,
          hintText: 'Full Name',
          isRequired: true,
          textStyle: $styles.text.bodySmall,
          hintTextStyle:
              $styles.text.bodySmall.copyWith(color: $styles.colors.greyMedium),
          contentPadding: EdgeInsets.symmetric(
            horizontal: $styles.insets.sm,
            vertical: $styles.insets.sm,
          ),
        ),
        SizedBox(height: $styles.insets.sm),
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
              color: $styles.colors.greyMedium,
            ),
            onPressed: viewModel.togglePasswordVisibility,
          ),
          textStyle: $styles.text.bodySmall,
          hintTextStyle:
              $styles.text.bodySmall.copyWith(color: $styles.colors.greyMedium),
          contentPadding: EdgeInsets.symmetric(
            horizontal: $styles.insets.sm,
            vertical: $styles.insets.sm,
          ),
        ),
        SizedBox(height: $styles.insets.sm),
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
              color: $styles.colors.greyMedium,
            ),
            onPressed: viewModel.toggleConfirmPasswordVisibility,
          ),
          textStyle: $styles.text.bodySmall,
          hintTextStyle:
              $styles.text.bodySmall.copyWith(color: $styles.colors.greyMedium),
          contentPadding: EdgeInsets.symmetric(
            horizontal: $styles.insets.sm,
            vertical: $styles.insets.sm,
          ),
        ),
        SizedBox(height: $styles.insets.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Divider(color: $styles.colors.greyMedium)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: $styles.insets.sm),
              child: Text(
                $strings.or,
                style: TextStyle(height: 1, color: $styles.colors.greyMedium),
              ),
            ),
            Expanded(child: Divider(color: $styles.colors.greyMedium)),
          ],
        ),
        SizedBox(height: $styles.insets.xl),
        SocialAuthButton(
          ref: ref,
          text: 'Sign up with Google',
          icon: Icons.g_mobiledata_rounded,
          iconColor: $styles.colors.black,
          onPressed: () {
            _handleSocialLogin(
                context, ref, ref.read(authServiceProvider).signInWithGoogle);
          },
        ),
        if ((isIOS || !isAndroid)) ...[
          SizedBox(height: $styles.insets.xs),
          SocialAuthButton(
            ref: ref,
            text: 'Sign up with Apple',
            icon: Icons.apple,
            iconColor: $styles.colors.black,
            onPressed: () {
              _handleSocialLogin(
                  context, ref, ref.read(authServiceProvider).signInWithApple);
            },
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  void _handleSocialLogin(BuildContext context, WidgetRef ref,
      Future<void> Function() signInMethod) async {
    final viewModel = ref.read(loginViewModelProvider.notifier);

    try {
      await socialSignInAndFinalize(context, ref, signInMethod);
    } catch (e) {
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
