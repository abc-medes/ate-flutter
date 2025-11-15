import 'package:bodido/common_libs.dart';
import 'package:bodido/core/widgets/typewriter_animated_text.dart';
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
  final bool isChat; // ADD

  const TrackingQuestionsSection({
    super.key,
    required this.isLoading,
    required this.questions,
    required this.selectedOptions,
    this.isSaving = false,
    this.onSavePressed,
    this.onOptionSelected,
    this.isChat = false, // ADD
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: $styles.insets.md),
            child: Center(
              child: TypewriterAnimatedText(
                [
                  $strings.tq_loading_1,
                  $strings.tq_loading_2,
                  $strings.tq_loading_3,
                ],
                textStyle: $styles.text.body.copyWith(
                  color: isChat ? Colors.white : $styles.colors.accent1,
                ),
                typingSpeed: const Duration(milliseconds: 40),
                pauseBetween: const Duration(milliseconds: 800),
                loop: true,
                enableVibration: false,
              ),
            ),
          )
        else if (questions.isEmpty)
          Text($strings.tq_empty, style: $styles.text.bodySmall)
        else ...[
          for (int i = 0; i < questions.length; i++) ...[
            TrackingQuestionCard(
              question: questions[i],
              selectedOptionId: selectedOptions[questions[i].id],
              onOptionSelected: onOptionSelected,
              isChat: isChat,
            ),
            if (i < questions.length - 1) SizedBox(height: $styles.insets.xs),
          ]
        ],
      ],
    );
  }
}
