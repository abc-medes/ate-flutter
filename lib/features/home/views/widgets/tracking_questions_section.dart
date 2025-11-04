import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/tracking_question_model.dart';
import 'package:bodido/features/home/views/widgets/tracking_question_card.dart';

class TrackingQuestionsSection extends StatelessWidget {
  final bool isLoading;
  final List<TrackingQuestion> questions;
  final Map<String, String> selectedOptions;
  final bool isSaving;
  final VoidCallback? onSavePressed;
  final void Function(TrackingQuestion q, QuestionOption option)?
      onOptionSelected;

  const TrackingQuestionsSection({
    super.key,
    required this.isLoading,
    required this.questions,
    required this.selectedOptions,
    this.isSaving = false,
    this.onSavePressed,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedOptions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: const LinearProgressIndicator(minHeight: 2),
          )
        else if (questions.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Text('No questions yet.', style: $styles.text.bodySmall),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: questions.length,
              separatorBuilder: (_, __) => SizedBox(height: $styles.insets.sm),
              itemBuilder: (context, index) {
                final q = questions[index];
                return TrackingQuestionCard(
                  question: q,
                  selectedOptionId: selectedOptions[q.id], // map drives UI
                  onOptionSelected: onOptionSelected,
                );
              },
            ),
          ),
      ],
    );
  }
}
