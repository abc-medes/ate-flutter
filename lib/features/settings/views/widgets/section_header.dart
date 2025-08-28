// lib/features/settings/views/widgets/section_header.dart
import 'package:regene/common_libs.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: $styles.text.h3.copyWith(
        color: $styles.colors.accent1,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
