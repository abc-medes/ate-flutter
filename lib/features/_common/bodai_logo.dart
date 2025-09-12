import 'package:bodai/common_libs.dart';

class BodaiLogo extends StatelessWidget {
  /// Optional: let callers pick a size or colour if they want.
  const BodaiLogo({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/logo/bodai_logo.png', // make sure the path matches pubspec.yaml
        fit: BoxFit.contain,
      ),
    );
  }
}
