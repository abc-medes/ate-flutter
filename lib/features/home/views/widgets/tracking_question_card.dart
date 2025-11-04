import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/tracking_question_model.dart';

class TrackingQuestionCard extends StatelessWidget {
  final TrackingQuestion question;
  final String? selectedOptionId;
  final void Function(TrackingQuestion q, QuestionOption option)?
      onOptionSelected;

  const TrackingQuestionCard({
    super.key,
    required this.question,
    this.selectedOptionId,
    this.onOptionSelected,
  });

  // Use centralized brand palette from $styles.colors

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all($styles.insets.md),
      decoration: BoxDecoration(
        color: $styles.colors.backgroundDark,
        borderRadius: BorderRadius.circular($styles.insets.sm),
        border: Border.all(
            color: $styles.colors.accent1.withOpacity(0.20), width: 1),
        boxShadow: [
          BoxShadow(
            color: $styles.colors.accent1.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            $styles.colors.accent1.withOpacity(0.05),
            $styles.colors.accent3.withOpacity(0.04),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // avoid unbounded stretch
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: $styles.colors.accent1.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.health_and_safety,
                    size: 18, color: $styles.colors.accent1),
              ),
              SizedBox(width: $styles.insets.sm),
              Text(
                question.questionTag.toUpperCase(),
                style: $styles.text.caption.copyWith(
                  letterSpacing: 0.5,
                  color: $styles.colors.accent1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _PriorityDot(priority: question.priority),
            ],
          ),

          SizedBox(height: $styles.insets.sm),

          // Question text
          Text(
            question.question,
            style: $styles.text.bodyBold.copyWith(
              fontSize: 16.0,
              height: 1.4, // safe line height
            ),
          ),

          SizedBox(height: $styles.insets.sm),

          // Meta pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(
                  label: 'System: ${question.system.name}',
                  color: $styles.colors.accent2),
              _MetaPill(
                  label: 'Metric: ${question.metric}',
                  color: $styles.colors.accent1),
              _MetaPill(
                  label: 'Category: ${question.category}',
                  color: $styles.colors.accent3),
            ],
          ),

          SizedBox(height: $styles.insets.md),

          // Options
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: question.options.map((opt) {
              final isSelected = selectedOptionId == opt.id;
              return ChoiceChip(
                label: Text(
                  opt.label,
                  style: $styles.text.bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : $styles.colors.accent1.withOpacity(0.9),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                backgroundColor: $styles.colors.accent1.withOpacity(0.10),
                selectedColor: $styles.colors.accent1,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected
                        ? $styles.colors.accent1
                        : $styles.colors.accent1.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                onSelected: (_) => onOptionSelected?.call(question, opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: $styles.text.caption.copyWith(
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final double priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final clamped = priority.clamp(0.0, 1.0);
    final color = Color.lerp(
      $styles.colors.accent3,
      $styles.colors.accent1,
      clamped,
    )!;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
