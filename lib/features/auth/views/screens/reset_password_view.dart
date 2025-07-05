import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/features/auth/view_models/login_view_model.dart';
import 'package:regene/core/widgets/customed_text_input.dart';
import 'package:regene/features/auth/views/widgets/email_sent_step.dart';

class ResetPasswordView extends ConsumerStatefulWidget {
  const ResetPasswordView({super.key});

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  late final LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ref.read(loginViewModelProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(loginViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            ref.invalidate(loginViewModelProvider);
            Navigator.pop(context);
          },
        ),
        title: Text(
          $strings.resetPasswordTitle,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (viewState.currentStep == LoginStep.resettingEmailSent)
                Expanded(
                    child: EmailSentStep(
                  title: 'Check Your Email',
                  description:
                      "We've sent a password reset approval link to ${viewState.emailController.text}. Please check your inbox and follow the instructions to reset your password.",
                  nextStepsTitle: 'Next steps:',
                  nextSteps: [
                    'Check your email inbox for a password reset link.',
                    'Click on the link in the email to reset your password.',
                  ],
                  resendButtonText: "Didn't receive the email? Resend",
                  onResend: viewState.isLoading
                      ? null
                      : () async {/* resend logic */},
                  backToLoginText: 'Back to Login',
                  onBackToLogin: () => context.go(RouteNames.login),
                  isLoading: viewState.isLoading,
                )),
              if (viewState.currentStep == LoginStep.emailInput)
                Expanded(
                  child: EmailInputStep(
                      viewState: viewState, viewModel: viewModel),
                ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: viewState.isLoading
                      ? null
                      : () async {
                          viewModel.handleForgotPassword(context);
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
                    $strings.sendEmail,
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

class EmailInputStep extends StatelessWidget {
  const EmailInputStep({
    super.key,
    required this.viewState,
    required this.viewModel,
  });

  final LoginState viewState;
  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomedTextInput(
          controller: viewState.emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => viewModel.onEmailChanged(),
          enabled: !viewState.isLoading,
          errorText:
              !viewState.isEmailValid ? 'Please enter a valid email' : null,
        ),
      ],
    );
  }
}
