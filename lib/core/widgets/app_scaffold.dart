import 'package:ate_project/common_libs.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});
  final Widget child;
  static AppStyle get style => _style;
  static AppStyle _style = AppStyle();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    Animate.defaultDuration = _style.times.fast;
    _style = AppStyle(
        screenSize: context.sizePx,
        disableAnimations: mq.disableAnimations,
        highContrast: mq.highContrast);
    return KeyedSubtree(
      key: ValueKey($styles.scale),
      child: Theme(
        data: $styles.colors.toThemeData(),
        child: DefaultTextStyle(
          style: $styles.text.h1,
          child: child,
        ),
      ),
    );
  }
}
