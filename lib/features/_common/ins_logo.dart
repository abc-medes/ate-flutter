import 'package:ate_project/common_libs.dart';

class InsLogo extends StatelessWidget {
  /// Optional: let callers pick a size or colour if they want.
  const InsLogo({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: $styles.colors.accent1,
        borderRadius: BorderRadius.circular(size * 0.23), // generous rounding
      ),
      child: Text(
        'INS',
        style: TextStyle(
          color: $styles.colors.offWhite,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
    );
  }
}
