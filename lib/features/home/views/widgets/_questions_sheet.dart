import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:bodido/features/home/view_models/home_view_model.dart';
import 'package:bodido/features/home/views/widgets/tracking_questions_section.dart';

class QuestionsSheet extends ConsumerWidget {
  const QuestionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: $styles.colors.background,
          body: Padding(
            padding: EdgeInsets.fromLTRB(
              $styles.insets.md,
              $styles.insets.md,
              $styles.insets.md,
              0,
            ),
            child: SingleChildScrollView(
              child: TrackingQuestionsSection(
                isLoading: state.isLoadingUserQuestions,
                questions: state.userQuestions,
                selectedOptions: state.selectedOptions,
                isSaving: state.isSavingSelections,
                onOptionSelected: (q, opt) =>
                    vm.selectQuestionOptionLocal(q, opt),
              ),
            ),
          ),
          bottomNavigationBar: _QuestionsBottomBar(
            state: state,
            onUpdatePressed: state.isSavingSelections
                ? null
                : () async {
                    await vm.commitSelectedTrackingOptions();
                  },
            onAskAiPressed: () {
              final selected = state.selectedOptions;
              if (selected.isEmpty) return;

              final qs = state.userQuestions;
              final lines = <String>[];
              for (final entry in selected.entries) {
                final q = qs.firstWhere(
                  (x) => x.id == entry.key,
                  orElse: () => qs.first,
                );
                final opt = q.options.firstWhere(
                  (o) => o.id == entry.value,
                  orElse: () => q.options.first,
                );
                lines.add('- ${q.question}: ${opt.label}');
              }

              final prompt = [
                'Here are my latest updates:',
                ...lines,
                'Please provide guidance and next steps.',
              ].join('\n');

              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please sign in to start chat'),
                  ),
                );
                return;
              }

              final sessionId = 'qs-${DateTime.now().millisecondsSinceEpoch}';

              final msg = ChatMessageDTO(
                userId: userId,
                sessionId: sessionId,
                message: prompt,
                isUser: true,
                createdAt: DateTime.now(),
                clientLocalTimestamp: DateTime.now(),
              );

              context.push(
                RouteNames.chat,
                extra: {
                  'initialMessage': msg,
                  'sessionIds': [sessionId],
                  'selectedDate': DateTime.now(),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuestionsBottomBar extends StatelessWidget {
  const _QuestionsBottomBar({
    super.key,
    required this.state,
    required this.onUpdatePressed,
    required this.onAskAiPressed,
  });

  final HomeViewState state;
  final Future<void> Function()? onUpdatePressed;
  final VoidCallback onAskAiPressed;

  @override
  Widget build(BuildContext context) {
    if (state.selectedOptions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        $styles.insets.sm,
        $styles.insets.md,
        $styles.insets.md + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: $styles.colors.background,
        border: Border(
          top: BorderSide(
            color: $styles.colors.accent1.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: state.isSavingSelections
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  state.isSavingSelections ? 'Updating...' : 'Update status',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: $styles.colors.accent1,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: $styles.insets.sm,
                  ),
                ),
                onPressed: state.isSavingSelections ? null : onUpdatePressed,
              ),
            ),
            SizedBox(width: $styles.insets.sm),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Ask AI'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: $styles.colors.accent1.withOpacity(0.4),
                  ),
                  foregroundColor: $styles.colors.accent1,
                  padding: EdgeInsets.symmetric(
                    vertical: $styles.insets.sm,
                  ),
                ),
                onPressed: onAskAiPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
