// lib/core/widgets/page_header.dart
import 'package:bodido/common_libs.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        mq.padding.top,
        $styles.insets.md,
        $styles.insets.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularIconButton(
            icon: Icons.arrow_back,
            size: 48,
            iconColor: $styles.colors.accent1,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          Text(title,
              style: $styles.text.h3.copyWith(color: $styles.colors.accent1)),
          trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}
