import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:bodai/core/routes/route_names.dart';

/// Helper class for showing authentication prompts throughout the app
class AuthPromptHelper {
  /// Shows a Cupertino-style dialog prompting the user to login
  /// Returns true if the user chose to login, false otherwise
  static Future<bool> showLoginPrompt(
    BuildContext context, {
    String title = 'Sign In',
    String message = 'Please sign in to access all features',
  }) async {
    return await showCupertinoDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: false,
                child: const Text('Not Now'),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Sign In'),
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
        title: const Text('Sign In Options'),
        message: const Text('Choose how you would like to sign in'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              if (onEmailLogin != null)
                onEmailLogin();
              else
                context.push(RouteNames.login);
            },
            child: const Text('Sign in with Email'),
          ),
          if (onGoogleLogin != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onGoogleLogin();
              },
              child: const Text('Sign in with Google'),
            ),
          if (onAppleLogin != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onAppleLogin();
              },
              child: const Text('Sign in with Apple'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  /// Shows a feature-locked prompt when a user tries to access a feature that requires login
  static Future<bool> showFeatureLockedPrompt(
    BuildContext context, {
    String title = 'Sign In Required',
    String message =
        'This feature requires an account. Would you like to sign in?',
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: false,
            child: const Text('Not Now'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Sign In'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
