import 'package:flutter/material.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/core/utils/auth_error_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/routes/route_names.dart';

class ErrorSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required List<ErrorAction> actions,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 8),
    bool showDismissAction = true,
  }) {
    // Ensure we have a valid context
    if (!context.mounted) return;

    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);

    // Hide any existing snackbars
    scaffoldMessenger.hideCurrentSnackBar();

    // If showDismissAction is true and onDismiss is provided, add a dismiss action
    final List<ErrorAction> allActions = List.from(actions);
    if (showDismissAction && onDismiss != null) {
      allActions.add(
        ErrorAction(
          label: 'Dismiss',
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
            onDismiss();
          },
        ),
      );
    }

    // Ensure we're using the main BuildContext for the scaffold
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        // Show snackbar
        try {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.surface),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(color: AppColors.surface),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: duration,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8),
              action: allActions.isEmpty
                  ? null
                  : SnackBarAction(
                      label: allActions.length > 1
                          ? 'Actions'
                          : allActions.first.label,
                      textColor: AppColors.surface,
                      onPressed: () {
                        if (allActions.length > 1) {
                          _showActionSheet(context, message, allActions);
                        } else {
                          allActions.first.onPressed();
                        }
                      },
                    ),
            ),
          );

          // Log for debugging
          print('Error snackbar shown: $message');
        } catch (e) {
          print('Error showing snackbar: $e');
        }
      }
    });
  }

  /// Shows a bottom sheet with all available actions for the error
  static void _showActionSheet(
      BuildContext context, String message, List<ErrorAction> actions) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...actions
                .map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            action.onPressed();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: action.isPrimary
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(action.label),
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  static void showLoginError({
    required BuildContext context,
    required String errorMessage,
    required VoidCallback clearError,
    VoidCallback? onTryAgain,
    VoidCallback? onResetPassword,
    VoidCallback? onCreateAccount,
  }) {
    final String userFriendlyError = errorMessage;
    final String errorLower = errorMessage.toLowerCase();
    final List<ErrorAction> actions = [];

    if (errorLower.contains("incorrect") || errorLower.contains("invalid")) {
      if (onTryAgain != null) {
        actions.add(ErrorAction(
          label: 'Try again',
          onPressed: () {
            onTryAgain();
          },
        ));
      }

      if (onResetPassword != null) {
        actions.add(ErrorAction(
          label: 'Reset password',
          onPressed: onResetPassword,
        ));
      }
    } else if (errorLower.contains("not found") ||
        errorLower.contains("no account") ||
        errorLower.contains("don't have an account")) {
      if (onCreateAccount != null) {
        actions.add(ErrorAction(
          label: 'Create account',
          onPressed: onCreateAccount,
          isPrimary: true,
        ));
      }
    } else if (errorLower.contains("network") ||
        errorLower.contains("connection")) {
      if (onTryAgain != null) {
        actions.add(ErrorAction(
          label: 'Try again',
          onPressed: onTryAgain,
          isPrimary: true,
        ));
      }
    }

    show(
      context: context,
      message: userFriendlyError,
      actions: actions,
      onDismiss: clearError,
    );
  }

  static void showSignupError({
    required BuildContext context,
    required String errorMessage,
    required VoidCallback clearError,
    VoidCallback? onTryAgain,
    VoidCallback? onGoToLogin,
  }) {
    final String userFriendlyError = errorMessage;
    final String errorLower = errorMessage.toLowerCase();
    final List<ErrorAction> actions = [];

    // Add appropriate actions based on error type
    if (errorLower.contains('email') &&
        (errorLower.contains('exists') || errorLower.contains('already'))) {
      if (onGoToLogin != null) {
        actions.add(ErrorAction(
          label: 'Go to login',
          onPressed: onGoToLogin,
          isPrimary: true,
        ));
      }
    } else if (errorLower.contains('network') ||
        errorLower.contains('connection')) {
      if (onTryAgain != null) {
        actions.add(ErrorAction(
          label: 'Try again',
          onPressed: onTryAgain,
          isPrimary: true,
        ));
      }
    }

    show(
      context: context,
      message: userFriendlyError,
      actions: actions,
      onDismiss: clearError,
    );
  }
}

/// Represents an action that can be taken in response to an error
class ErrorAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  /// Creates an error action with a label and callback
  ErrorAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });
}
