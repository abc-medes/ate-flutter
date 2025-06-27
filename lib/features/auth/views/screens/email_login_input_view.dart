import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/features/auth/view_models/login_view_model.dart';
import 'package:ate_project/core/widgets/loading_view.dart';
import 'package:ate_project/core/widgets/error_snackbar.dart';
import 'package:ate_project/core/widgets/customed_text_input.dart';
import 'package:ate_project/features/auth/views/widgets/email_sent_step.dart';

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
          $strings.logIn,
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
                  child: EmailAndPasswordInputStep(
                      viewState: viewState, viewModel: viewModel),
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
                    $strings.logIn,
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

class EmailAndPasswordInputStep extends StatelessWidget {
  const EmailAndPasswordInputStep({
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
              onTap: () {
                viewModel.handleForgotPassword(context);
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
