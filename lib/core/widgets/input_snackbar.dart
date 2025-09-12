import 'package:bodai/common_libs.dart';

class InputSnackBar extends StatelessWidget {
  final String message;
  final bool processing;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final EdgeInsets? contentPadding;
  final double? iconSize;

  const InputSnackBar({
    super.key,
    required this.message,
    this.processing = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.contentPadding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? $styles.colors.backgroundDark;
    final fg = foregroundColor ?? $styles.colors.white;
    final h = height ?? ($styles.insets.xl * 1.2);
    final pad =
        contentPadding ?? EdgeInsets.symmetric(horizontal: $styles.insets.sm);
    final iSize = iconSize ?? $styles.insets.md;

    return Container(
      height: h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular($styles.corners.sm),
      ),
      padding: pad,
      child: Row(
        children: [
          if (processing && icon == null)
            SizedBox(
              width: iSize,
              height: iSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fg),
              ),
            )
          else if (icon != null)
            Icon(icon, size: iSize, color: fg),
          SizedBox(width: $styles.insets.sm),
          Expanded(
            child: Text(
              message,
              style: $styles.text.bodySmall.copyWith(color: fg),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// New: Snackbar helpers (use SnackBar widget; do not inline custom Container)
class InputSnackbar {
  static void _show(
    BuildContext context, {
    required Widget content,
    required Color background,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!context.mounted) return;
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(8),
        duration: duration,
      ),
    );
  }

  static void showProcessing(BuildContext context,
      {String message = 'Saving to memory...'}) {
    _show(
      context,
      content: Row(
        children: [
          SizedBox(
            width: $styles.insets.md,
            height: $styles.insets.md,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>($styles.colors.white),
            ),
          ),
          SizedBox(width: $styles.insets.sm),
          Expanded(
            child: Text(
              message,
              style:
                  $styles.text.bodySmall.copyWith(color: $styles.colors.white),
            ),
          ),
        ],
      ),
      background: $styles.colors.accent2,
      duration: const Duration(days: 1),
    );
  }

  static void showSuccess(BuildContext context,
      {String message = 'Saved to memory'}) {
    _show(
      context,
      content: Row(
        children: [
          Icon(Icons.check_circle_outline, color: $styles.colors.white),
          SizedBox(width: $styles.insets.sm),
          Expanded(
            child: Text(
              message,
              style:
                  $styles.text.bodySmall.copyWith(color: $styles.colors.white),
            ),
          ),
        ],
      ),
      background: $styles.colors.success,
    );
  }

  static void showError(BuildContext context,
      {String message = 'Failed to save'}) {
    _show(
      context,
      content: Row(
        children: [
          Icon(Icons.error_outline, color: $styles.colors.white),
          SizedBox(width: $styles.insets.sm),
          Expanded(
            child: Text(
              message,
              style:
                  $styles.text.bodySmall.copyWith(color: $styles.colors.white),
            ),
          ),
        ],
      ),
      background: $styles.colors.error,
    );
  }
}
