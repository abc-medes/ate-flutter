import 'package:bodiapp/common_libs.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: Theme.of(context).textTheme.bodyMedium,
            obscureText: obscureText,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: isRequired ? '$hintText *' : hintText,
              hintStyle: TextStyle(color: AppColors.textTertiary),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}
