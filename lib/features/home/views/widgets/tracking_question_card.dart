import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/tracking_question_model.dart';

class TrackingQuestionCard extends StatelessWidget {
  final TrackingQuestion question;
  final String? selectedOptionId;
  final void Function(TrackingQuestion q, QuestionOption option)?
      onOptionSelected;
  final bool isChat;

  const TrackingQuestionCard({
    super.key,
    required this.question,
    this.selectedOptionId,
    this.onOptionSelected,
    this.isChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final containerColor =
        isChat ? Colors.white.withOpacity(0.6) : $styles.colors.backgroundDark;
    final borderColor = isChat
        ? Colors.white.withOpacity(0.12)
        : $styles.colors.accent1.withOpacity(0.20);
    final gradientColors = isChat
        ? [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.04)]
        : [
            $styles.colors.accent1.withOpacity(0.05),
            $styles.colors.accent3.withOpacity(0.04),
          ];
    final tagColor = isChat ? Colors.white : $styles.colors.accent1;

    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all($styles.insets.sm),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular($styles.insets.sm),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: (isChat ? Colors.black : $styles.colors.accent1)
                .withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (isChat ? Colors.white : $styles.colors.accent1)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.health_and_safety,
                    size: 16,
                    color: isChat ? Colors.white : $styles.colors.accent1),
              ),
              SizedBox(width: $styles.insets.xs),
              Expanded(
                child: Text(
                  question.questionTag.toUpperCase(),
                  style: $styles.text.caption.copyWith(
                    letterSpacing: 0.5,
                    color: tagColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              SizedBox(width: $styles.insets.xs),
              _PriorityDot(priority: question.priority),
            ],
          ),

          SizedBox(height: $styles.insets.xs),

          // Question text
          Text(
            question.question,
            style: $styles.text.bodyBold.copyWith(
              fontSize: 15.0,
              height: 1.3,
              color: isChat ? Colors.white : null, // ADD
            ),
          ),

          SizedBox(height: $styles.insets.xs),

          // Meta pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaPill(
                label: $strings.meta_system(question.system.name),
                color: isChat ? Colors.white : $styles.colors.accent2, // ADD
              ),
              _MetaPill(
                label: $strings.meta_metric(question.metric),
                color: isChat ? Colors.white : $styles.colors.accent1, // ADD
              ),
              _MetaPill(
                label: $strings.meta_category(question.category),
                color: isChat ? Colors.white : $styles.colors.accent3, // ADD
              ),
            ],
          ),

          SizedBox(height: $styles.insets.sm),

          // Options
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: question.options.map((opt) {
              final isSelected = selectedOptionId == opt.id;
              final labelStyleChat = $styles.text.bodySmall.copyWith(
                color: isSelected ? Colors.white : $styles.colors.accent1,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              );
              final labelStyleHome = $styles.text.bodySmall.copyWith(
                color: isSelected ? Colors.white : $styles.colors.accent1,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              );

              return ChoiceChip(
                label: Text(
                  opt.label,
                  style: isChat ? labelStyleChat : labelStyleHome, // ADD
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                selected: isSelected,
                backgroundColor:
                    $styles.colors.accent1.withOpacity(0.08), // CHANGED
                selectedColor:
                    isChat ? Colors.white : $styles.colors.accent1, // CHANGED
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isChat
                        ? (isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.30))
                        : (isSelected
                            ? $styles.colors.accent1
                            : $styles.colors.accent1.withOpacity(0.30)), // ADD
                    width: 1,
                  ),
                ),
                avatar: null,
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
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.28),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}

final _eventReadyRe = RegExp(
  r'\{[^{}]*"event"\s*:\s*"tracking_questions_ready"[^{}]*\}',
  multiLine: true,
);

String stripBackendEventTokens(String s) =>
    s.replaceAll(_eventReadyRe, '').trim();
