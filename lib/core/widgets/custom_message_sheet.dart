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

class CustomMessageSheet {
  static Future<void> show({
    required BuildContext context,
    String title = 'Message',
    required String message,
    List<MessageAction> actions = const [],
    VoidCallback? onDismiss,
  }) async {
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...actions
                .map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
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
      ),
    );
    if (onDismiss != null) onDismiss();
  }

  static void showError({
    required BuildContext context,
    required String message,
    List<MessageAction> actions = const [],
    VoidCallback? onDismiss,
    String title = 'Error',
  }) {
    show(
      context: context,
      title: title,
      message: message,
      actions: actions,
      onDismiss: onDismiss,
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    List<MessageAction> actions = const [],
    VoidCallback? onDismiss,
    String title = 'Success',
  }) {
    show(
      context: context,
      title: title,
      message: message,
      actions: actions,
      onDismiss: onDismiss,
    );
  }
}