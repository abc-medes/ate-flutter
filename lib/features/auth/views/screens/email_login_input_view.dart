import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/app_button.dart';
import 'package:bodido/core/widgets/clickable_text.dart';
import 'package:bodido/core/widgets/customed_text_input.dart';
import 'package:bodido/core/widgets/page_header.dart';
import 'package:bodido/features/auth/view_models/login_view_model.dart';

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
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          AppPageAppBar(
            title: $strings.logIn,
            onBack: () {
              ref.invalidate(loginViewModelProvider);
              Navigator.of(context).maybePop();
            },
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all($styles.insets.md),
                child: Column(
                  children: [
                    if (viewState.currentStep == LoginStep.emailInput)
                      Expanded(
                        child: EmailAndPasswordInputStep(
                            viewState: viewState, viewModel: viewModel),
                      ),
                    AppButton(
                      label: $strings.logIn,
                      isLoading: viewState.isLoading,
                      onPressed: viewState.isLoading
                          ? null
                          : () async {
                              await viewModel.handlePasswordLogin(context);
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
          hintText: $strings.fieldEmail,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => viewModel.onEmailChanged(),
          enabled: !viewState.isLoading,
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
          controller: viewState.passwordController,
          hintText: $strings.fieldPassword,
          obscureText: !viewState.isPasswordVisible,
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
        ClickableText(
          text: $strings.forgotPassword,
          onTap: () => context.replace(RouteNames.resetPassword),
          padding: EdgeInsets.only(top: $styles.insets.xs),
        ),
      ],
    );
  }
}
