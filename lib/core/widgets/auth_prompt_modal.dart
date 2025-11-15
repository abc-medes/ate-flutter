import 'package:flutter/cupertino.dart';
import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';

class AuthPromptHelper {
  static Future<bool> showLoginPrompt(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    return await showCupertinoDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => CupertinoAlertDialog(
            title: Text(title ?? $strings.auth_sign_in),
            content: Text(message ?? $strings.auth_sign_in_request),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: false,
                child: Text($strings.auth_not_now),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text($strings.auth_sign_in),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Shows a Cupertino-style action sheet with login options
  static Future<void> showLoginActionSheet(
    BuildContext context, {
    VoidCallback? onEmailLogin,
    VoidCallback? onGoogleLogin,
    VoidCallback? onAppleLogin,
  }) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text($strings.auth_sign_in_options),
        message: Text($strings.auth_choose_sign_in),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              if (onEmailLogin != null)
                onEmailLogin();
              else
                context.push(RouteNames.login);
            },
            child: Text($strings.auth_sign_in_email),
          ),
          if (onGoogleLogin != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onGoogleLogin();
              },
              child: Text($strings.auth_sign_in_google),
            ),
          if (onAppleLogin != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onAppleLogin();
              },
              child: Text($strings.auth_sign_in_apple),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: Text($strings.action_cancel),
        ),
      ),
    );
  }

  /// Shows a feature-locked prompt when a user tries to access a feature that requires login
  static Future<bool> showFeatureLockedPrompt(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title ?? $strings.auth_sign_in_required),
        content: Text(message ?? $strings.auth_feature_locked),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: false,
            child: Text($strings.auth_not_now),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text($strings.auth_sign_in),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
