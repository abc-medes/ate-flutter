import 'package:bodido/common_libs.dart';

class MessageAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  const MessageAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });
}

enum MessageTone { normal, success, error }

class CustomMessageSheet {
  static Future<void> show({
    required BuildContext context,
    String? title,
    required String message,
    List<MessageAction> actions = const [],
    VoidCallback? onDismiss,
    MessageTone tone = MessageTone.normal,
  }) async {
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular($styles.corners.md)),
      ),
      builder: (ctx) {
        final isError = tone == MessageTone.error;
        final isSuccess = tone == MessageTone.success;
        final Color titleColor = isError
            ? $styles.colors.error
            : isSuccess
                ? $styles.colors.success
                : AppColors.textPrimary;

        return Container(
          padding: EdgeInsets.all($styles.corners.lg),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? $strings.msg_title_generic,
                style: TextStyle(
                  fontSize: $styles.text.h3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              SizedBox(height: $styles.insets.sm),
              Text(
                message,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: $styles.insets.md),
              ...actions
                  .map((action) => Padding(
                        padding: EdgeInsets.only(bottom: $styles.insets.sm),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
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
        );
      },
    );
    if (onDismiss != null) onDismiss();
  }

  static void showError({
    required BuildContext context,
    required String message,
    List<MessageAction> actions = const [],
    VoidCallback? onDismiss,
    String? title,
  }) {
    show(
      context: context,
      title: title ?? $strings.msg_title_error,
      message: message,
      actions: actions,
      onDismiss: onDismiss,
      tone: MessageTone.error,
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    List<MessageAction> actions = const [],
    VoidCallback? onDismiss,
    String? title,
  }) {
    show(
      context: context,
      title: title ?? $strings.msg_title_success,
      message: message,
      actions: actions,
      onDismiss: onDismiss,
      tone: MessageTone.success,
    );
  }
}
