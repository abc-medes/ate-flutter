import 'dart:io';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/app_button.dart';
import 'package:bodido/core/widgets/custom_message_sheet.dart';
import 'package:bodido/core/widgets/customed_text_input.dart';
import 'package:bodido/core/widgets/loading_view.dart';
import 'package:bodido/core/widgets/page_header.dart';
import 'package:bodido/features/auth/view_models/signup_view_model.dart';
import 'package:bodido/features/auth/views/widgets/email_sent_step.dart';
import 'package:bodido/features/auth/views/widgets/social_login_button.dart';

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

        CustomMessageSheet.showError(
          context: context,
          message: viewState.error!,
          actions: [
            MessageAction(
                label: 'Try Again', onPressed: () => viewModel.signUp()),
            MessageAction(
                label: 'Go to Login',
                onPressed: () => context.go(RouteNames.login)),
          ],
          onDismiss: () => viewModel.clearError(),
        );
      }
    });

    return Scaffold(
      backgroundColor: $styles.colors.background,
      appBar: AppPageAppBar(
        title: 'Sign Up',
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
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
                                    : () async {
                                        try {
                                          await viewModel
                                              .resendVerificationEmail();
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  'Verification email resent'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  $styles.colors.accent1,
                                              duration:
                                                  const Duration(seconds: 2),
                                            ),
                                          );
                                        } catch (_) {}
                                      },
                                backToLoginText: 'Back to Login',
                                onBackToLogin: () =>
                                    context.go(RouteNames.login),
                                isLoading: viewState.isLoading,
                              ),
                          ],
                        ),
                      ),
                    ),
                    AppButton(
                      label: 'Continue',
                      isLoading: viewState.isLoading,
                      onPressed: () async {
                        switch (viewState.currentStep) {
                          case SignupStep.detailsInput:
                            await viewModel.signUp();
                            break;
                          case SignupStep.emailSent:
                            await viewModel.handleLogin(
                                context, SignupMethod.email);
                            break;
                          default:
                            break;
                        }
                      },
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
            viewModel.handleLogin(context, SignupMethod.google);
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
              viewModel.handleLogin(context, SignupMethod.apple);
            },
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}
