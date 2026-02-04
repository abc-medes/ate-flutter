import 'package:bodido/common_libs.dart';

/// Stub — home was reset. Replace when you add questions again.
class QuestionsSheet extends StatelessWidget {
  const QuestionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: $styles.colors.background,
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        builder: (_, controller) => Center(
          child: Text(
            'Questions',
            style: $styles.text.body.copyWith(color: $styles.colors.caption),
          ),
        ),
      ),
    );
  }
}
