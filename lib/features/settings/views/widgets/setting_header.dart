import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

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
            iconColor: $styles.colors.black,
            onTap: () => context.go(RouteNames.home),
          ),
          Text($strings.settings_title, style: $styles.text.h3),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
