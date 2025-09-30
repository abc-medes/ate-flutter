import 'dart:io';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/core/widgets/app_button.dart';
import 'package:bodido/core/widgets/custom_message_sheet.dart';
import 'package:bodido/core/widgets/customed_text_input.dart';
import 'package:bodido/core/widgets/page_header.dart';

class ChangePasswordView extends ConsumerStatefulWidget {
  const ChangePasswordView({super.key});

  @override
  ConsumerState<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends ConsumerState<ChangePasswordView> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isCurrentVisible = false;
  bool _isNewVisible = false;
  bool _isConfirmVisible = false;

  bool _isNewValid = true;
  bool _doMatch = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validateNew() {
    final password = _newController.text;
    final isValid = password.length >= 8 && RegExp(r'\d').hasMatch(password);
    setState(() => _isNewValid = isValid);
    return isValid;
  }

  bool _validateMatch() {
    final match = _newController.text == _confirmController.text;
    setState(() => _doMatch = match);
    return match;
  }

  Future<void> _submit() async {
    final valid = _validateNew() & _validateMatch();
    if (!valid) {
      CustomMessageSheet.showError(
        context: context,
        message: 'Please correct the errors before continuing',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );

      if (!mounted) return;
      CustomMessageSheet.showSuccess(
        context: context,
        message: 'Password updated',
        onDismiss: () => Navigator.of(context).pop(),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      CustomMessageSheet.showError(
        context: context,
        message: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      CustomMessageSheet.showError(
        context: context,
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAndroid = Platform.isAndroid;
    final bool isIOS = Platform.isIOS;

    return Scaffold(
      backgroundColor: $styles.colors.background,
      appBar: AppPageAppBar(
        title: 'Change Password',
        onBack: () => context.go(RouteNames.settings),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all($styles.insets.md),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomedTextInput(
                        controller: _currentController,
                        hintText: 'Current Password',
                        isRequired: true,
                        obscureText: !_isCurrentVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isCurrentVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: $styles.colors.greyMedium,
                          ),
                          onPressed: () => setState(
                              () => _isCurrentVisible = !_isCurrentVisible),
                        ),
                        textStyle: $styles.text.bodySmall,
                        hintTextStyle: $styles.text.bodySmall
                            .copyWith(color: $styles.colors.greyMedium),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: $styles.insets.sm,
                          vertical: $styles.insets.sm,
                        ),
                      ),
                      SizedBox(height: $styles.insets.sm),
                      CustomedTextInput(
                        controller: _newController,
                        hintText: 'New Password',
                        isRequired: true,
                        obscureText: !_isNewVisible,
                        onChanged: (_) => _validateNew(),
                        errorText: !_isNewValid
                            ? 'Password must be at least 8 characters with at least 1 number'
                            : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: $styles.colors.greyMedium,
                          ),
                          onPressed: () =>
                              setState(() => _isNewVisible = !_isNewVisible),
                        ),
                        textStyle: $styles.text.bodySmall,
                        hintTextStyle: $styles.text.bodySmall
                            .copyWith(color: $styles.colors.greyMedium),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: $styles.insets.sm,
                          vertical: $styles.insets.sm,
                        ),
                      ),
                      SizedBox(height: $styles.insets.sm),
                      CustomedTextInput(
                        controller: _confirmController,
                        hintText: 'Confirm New Password',
                        isRequired: true,
                        obscureText: !_isConfirmVisible,
                        onChanged: (_) => _validateMatch(),
                        errorText: !_doMatch ? 'Passwords do not match' : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: $styles.colors.greyMedium,
                          ),
                          onPressed: () => setState(
                              () => _isConfirmVisible = !_isConfirmVisible),
                        ),
                        textStyle: $styles.text.bodySmall,
                        hintTextStyle: $styles.text.bodySmall
                            .copyWith(color: $styles.colors.greyMedium),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: $styles.insets.sm,
                          vertical: $styles.insets.sm,
                        ),
                      ),
                      if (isIOS || isAndroid)
                        SizedBox(height: $styles.insets.xl),
                    ],
                  ),
                ),
              ),
              AppButton(
                label: 'Update Password',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
