import 'package:ate_project/common_libs.dart';

class DefaultTextColor extends StatelessWidget {
  const DefaultTextColor({super.key, required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(context).style.copyWith(color: color),
      child: child,
    );
  }
}
