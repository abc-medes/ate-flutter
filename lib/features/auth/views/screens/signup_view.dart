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
import 'package:bodido/features/auth/views/widgets/terms_consent_sheet.dart';

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
        LoadingScreen.show(context, message: $strings.authCreatingAccount);
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
                label: $strings.actionTryAgain, onPressed: () => viewModel.signUp()),
            MessageAction(
                label: $strings.actionGoToLogin,
                onPressed: () => context.go(RouteNames.login)),
          ],
          onDismiss: () => viewModel.clearError(),
        );
      }
    });

    return Scaffold(
      backgroundColor: $styles.colors.background,
      appBar: AppPageAppBar(
        title: $strings.signUp,
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
                                title: $strings.verifyYourEmail,
                                description: $strings.signupEmailSentDescription(viewState.emailController.text),
                                nextStepsTitle: $strings.nextSteps,
                                nextSteps: [
                                  $strings.signupNextStep1,
                                  $strings.signupNextStep2,
                                  $strings.signupNextStep3,
                                ],
                                resendButtonText: $strings.resendEmail,
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
                                              content: Text(
                                                  $strings.verificationEmailResent),
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
                                backToLoginText: $strings.actionBackToLogin,
                                onBackToLogin: () =>
                                    context.go(RouteNames.login),
                                isLoading: viewState.isLoading,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: $styles.insets.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            checkboxTheme: const CheckboxThemeData(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              splashRadius: 0,
                            ),
                          ),
                          child: Transform.scale(
                            scale: 1.25, // bigger checkbox
                            child: Checkbox(
                              value: viewState.acceptTerms,
                              onChanged: (v) async {
                                if (v == true) {
                                  final accepted = await TermsConsentSheet.show(
                                    context,
                                    termsUrl: Uri.parse(
                                        'https://yourdomain.com/terms'),
                                    privacyUrl: Uri.parse(
                                        'https://yourdomain.com/privacy'),
                                  );
                                  if (!mounted) return;
                                  viewModel
                                      .setAcceptedPolicies(accepted == true);
                                } else {
                                  viewModel.setAcceptedPolicies(false);
                                }
                              },
                              activeColor: $styles.colors.accent1,
                              checkColor: $styles.colors.white,
                              side: BorderSide(
                                  color: $styles.colors.greyMedium,
                                  width: 2), // unchecked border
                              visualDensity: VisualDensity.compact, // tighter
                            ),
                          ),
                        ),
                        SizedBox(width: $styles.insets.xs),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final accepted = await TermsConsentSheet.show(
                                context,
                                termsUrl:
                                    Uri.parse('https://yourdomain.com/terms'),
                                privacyUrl:
                                    Uri.parse('https://yourdomain.com/privacy'),
                              );
                              if (!mounted) return;
                              viewModel.setAcceptedPolicies(accepted == true);
                            },
                            child: Text.rich(
                              TextSpan(
                                style: $styles.text.bodySmall.copyWith(
                                  // make text bigger
                                  fontSize:
                                      ($styles.text.bodySmall.fontSize ?? 16) +
                                          2,
                                  color: $styles.colors.black,
                                ),
                                children: [
                                  TextSpan(text: $strings.iAgreeTo),
                                  TextSpan(
                                    text: $strings.termsTitle,
                                    // "seemingly clickable": accent color + underline
                                    style: $styles.text.bodySmall.copyWith(
                                      fontSize:
                                          ($styles.text.bodySmall.fontSize ??
                                                  16) +
                                              2,
                                      color: $styles.colors.accent1,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: $styles.insets.sm),
                    AppButton(
                      label: $strings.actionContinue,
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
          hintText: $strings.fieldEmail,
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => viewModel.validateEmail(),
          errorText:
              !viewState.isEmailValid ? $strings.errorInvalidEmailShort : null,
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
          hintText: $strings.fieldFullName,
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
          hintText: $strings.fieldPassword,
          isRequired: true,
          obscureText: !viewState.isPasswordVisible,
          onChanged: (_) => viewModel.validatePassword(),
          errorText: !viewState.isPasswordValid
              ? $strings.errorPasswordPolicy
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
          hintText: $strings.fieldConfirmPassword,
          isRequired: true,
          obscureText: !viewState.isConfirmPasswordVisible,
          onChanged: (_) => viewModel.validatePasswordsMatch(),
          errorText:
              !viewState.doPasswordsMatch ? $strings.errorPasswordsDoNotMatch : null,
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
          text: $strings.signUpWithGoogle,
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
            text: $strings.signUpWithApple,
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
