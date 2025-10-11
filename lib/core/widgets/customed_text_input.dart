import 'package:bodido/common_libs.dart';

class CustomedTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isRequired;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool enabled;
  final String? errorText;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? errorTextStyle;
  final EdgeInsetsGeometry? contentPadding;

  const CustomedTextInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.isRequired = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.suffixIcon,
    this.enabled = true,
    this.errorText,
    this.textStyle,
    this.hintTextStyle,
    this.errorTextStyle,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final textDir = Directionality.of(context);
    final EdgeInsets resolvedPadding = (contentPadding ??
            EdgeInsets.symmetric(
              horizontal: $styles.insets.sm,
              vertical: $styles.insets.sm,
            ))
        .resolve(textDir);

    final TextStyle baseFieldStyle = $styles.text.body;

    final TextStyle baseHintStyle = (hintTextStyle ??
        baseFieldStyle.copyWith(color: $styles.colors.greyMedium));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular($styles.corners.md),
          ),
          child: TextField(
            controller: controller,
            style: baseFieldStyle,
            obscureText: obscureText,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: isRequired ? '$hintText *' : hintText,
              hintStyle: baseHintStyle,
              contentPadding: resolvedPadding,
              border: InputBorder.none,
              suffixIcon: suffixIcon,
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(
              top: $styles.insets.xs,
              left: resolvedPadding.left,
            ),
            child: Text(
              errorText!,
              style: errorTextStyle ??
                  $styles.text.bodySmall.copyWith(color: $styles.colors.error),
            ),
          ),
      ],
    );
  }
}
