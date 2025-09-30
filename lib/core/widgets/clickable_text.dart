import 'package:bodido/common_libs.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle? style;
  final EdgeInsets? padding;
  final TextAlign? textAlign;

  const ClickableText({
    super.key,
    required this.text,
    required this.onTap,
    this.style,
    this.padding,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            textAlign: textAlign ?? TextAlign.center,
            style: style ??
                $styles.text.bodySmall.copyWith(color: $styles.colors.accent1),
          ),
        ),
      ),
    );
  }
}
