import 'package:bodido/common_libs.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedBg = backgroundColor ?? $styles.colors.accent1;
    final Color resolvedFg = foregroundColor ?? $styles.colors.white;
    final double resolvedHeight = height ?? $styles.insets.xl;
    final double resolvedRadius = borderRadius ?? $styles.corners.md;
    final TextStyle resolvedTextStyle =
        (textStyle ?? $styles.text.bodyBold).copyWith(color: resolvedFg);

    return SizedBox(
      width: double.infinity,
      height: resolvedHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedBg,
          foregroundColor: resolvedFg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: resolvedTextStyle.fontSize != null
                    ? resolvedTextStyle.fontSize! + 4
                    : 18,
                height: resolvedTextStyle.fontSize != null
                    ? resolvedTextStyle.fontSize! + 4
                    : 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(resolvedFg),
                ),
              )
            : Text(label, style: resolvedTextStyle),
      ),
    );
  }
}
