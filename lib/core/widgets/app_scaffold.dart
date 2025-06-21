import 'package:ate_project/common_libs.dart';
import 'package:ate_project/theme/styles.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});
  final Widget child;
  static AppStyle get style => _style;
  static AppStyle _style = AppStyle();

  @override
  Widget build(BuildContext context) {
    // Listen to the device size, and update AppStyle when it changes
    final mq = MediaQuery.of(context);
    // Set default timing for animations in the app
    Animate.defaultDuration = _style.times.fast;
    // Create a style object that will be passed down the widget tree
    _style = AppStyle(
        screenSize: context.sizePx,
        disableAnimations: mq.disableAnimations,
        highContrast: mq.highContrast);
    return KeyedSubtree(
      key: ValueKey($styles.scale),
      child: Theme(
        data: $styles.colors.toThemeData(),
        // Provide a default texts style to allow Hero's to render text properly
        child: DefaultTextStyle(
          style: $styles.text.body,
          // Use a custom scroll behavior across entire app
          child: child,
        ),
      ),
    );
  }
}
