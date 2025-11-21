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

    return Material(
      color: $styles.colors.background,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular($styles.insets.lg),
        topRight: Radius.circular($styles.insets.lg),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.25,
        maxChildSize: 0.95,
        builder: (_, controller) => DefaultTabController(
          length: 2,
          child: Column(
            children: [
              SizedBox(height: $styles.insets.sm),
              TabBar(
                labelColor: $styles.colors.accent1,
                unselectedLabelColor: $styles.colors.caption,
                labelStyle: $styles.text.bodyBold.copyWith(fontSize: 16),
                unselectedLabelStyle: $styles.text.body.copyWith(fontSize: 16),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: $styles.colors.accent1,
                tabs: [
                  Tab(text: $strings.qs_tab_questions, height: 48),
                  Tab(text: $strings.qs_tab_answered, height: 48),
                ],
              ),
              SizedBox(height: $styles.insets.sm),
              Expanded(
                child: TabBarView(
                  children: [
                    // Questions tab
                    ListView(
                      controller: controller,
                      padding: EdgeInsets.only(
                        top: $styles.insets.md,
                        bottom: $styles.insets.md,
                      ),
                      children: [
                        TrackingQuestionsSection(
                          isLoading: state.isLoadingUserQuestions,
                          questions: state.userQuestions,
                          selectedOptions: state.selectedOptions,
                          isSaving: state.isSavingSelections,
                          onOptionSelected: (q, opt) =>
                              vm.selectQuestionOptionLocal(q, opt),
                        ),
                      ],
                    ),
                    ListView(
                      controller: controller,
                      padding: EdgeInsets.only(
                        top: $styles.insets.md,
                        bottom: $styles.insets.md,
                      ),
                      children: [
                        Builder(builder: (_) {
                          final selectedForAnswered = <String, String>{
                            ...state.answeredOptions,
                            ...state.selectedOptions,
                          };
                          return TrackingQuestionsSection(
                            isLoading: state.isLoadingUserQuestions,
                            questions: state.answeredQuestions,
                            selectedOptions: selectedForAnswered,
                            isSaving: state.isSavingSelections,
                            onOptionSelected: (q, opt) =>
                                vm.selectQuestionOptionLocal(q, opt),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              _QuestionsBottomBar(
                state: state,
                onUpdatePressed: state.isSavingSelections
                    ? null
                    : () async {
                        await vm.commitSelectedTrackingOptions();
                      },
                onAskAiPressed: () async {
                  final selected = state.selectedOptions;
                  if (selected.isEmpty) return;

                  await vm.commitSelectedTrackingOptions();

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
                    $strings.qs_updates_intro,
                    ...lines,
                    $strings.qs_updates_request,
                  ].join('\n');

                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text($strings.qs_sign_in_required),
                      ),
                    );
                    return;
                  }

                  final sessionId =
                      'qs-${DateTime.now().millisecondsSinceEpoch}';

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
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionsBottomBar extends StatelessWidget {
  const _QuestionsBottomBar({
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
                  state.isSavingSelections
                      ? $strings.qs_update_updating
                      : $strings.qs_update_status,
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
                label: Text($strings.qs_ask_ai),
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
