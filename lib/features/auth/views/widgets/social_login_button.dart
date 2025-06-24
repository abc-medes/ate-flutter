import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.ref,
    required this.text,
    required this.iconColor,
    this.icon,
    required this.onPressed,
  });

  final WidgetRef ref;
  final String text;
  final IconData? icon;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: ref.watch(authProvider).isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.textTertiary.withAlpha(128)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: $styles.text.quote2.fontSize,
                ),
              ),
            ),
            Center(
              child: Text(text,
                  style: $styles.text.body.copyWith(
                    color: AppColors.textPrimary,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
