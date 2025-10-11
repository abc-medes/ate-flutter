import 'package:bodido/common_libs.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isDestructive;

  const SettingItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? $styles.colors.error : $styles.colors.accent1,
      ),
      title: Text(
        title,
        style: $styles.text.body.copyWith(
          color: isDestructive ? $styles.colors.error : $styles.colors.black,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: $styles.colors.caption,
          ),
      onTap: onTap,
      tileColor: $styles.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($styles.corners.sm),
      ),
    );
  }
}
