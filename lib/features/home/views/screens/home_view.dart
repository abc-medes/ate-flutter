import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/chat_input.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:bodido/features/home/view_models/home_view_model.dart';
import 'package:bodido/features/home/views/widgets/_insights_list.dart';
import 'package:bodido/features/home/views/widgets/chat_helper.dart';
import 'package:bodido/features/home/views/widgets/tappable_score.dart';
import 'package:bodido/features/home/views/widgets/tracking_questions_section.dart';
import 'package:intl/intl.dart';

// --- Main HomeView Widget ---
// Converted to ConsumerStatefulWidget to manage FocusNode
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          _buildHeader(context, state, ref),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InsightsList(
                    height: 440,
                    insights: state.insights,
                    isLoading: state.isLoadingInsights,
                  ),
                  SizedBox(height: $styles.insets.xl),
                  TrackingQuestionsSection(
                    isLoading: state.isLoadingUserQuestions,
                    questions: state.userQuestions,
                    selectedOptions: state.selectedOptions, // ADD
                    isSaving: state.isSavingSelections, // ADD
                    onSavePressed: () {
                      // ADD
                      ref
                          .read(homeViewModelProvider.notifier)
                          .commitSelectedTrackingOptions();
                    },
                    onOptionSelected: (q, opt) {
                      // ADD
                      ref
                          .read(homeViewModelProvider.notifier)
                          .selectQuestionOptionLocal(q, opt);
                    },
                  ),
                  SizedBox(height: $styles.insets.sm),
                ],
              ),
            ),
          ),
          ChatHelper(
            selectedChip: state.selectedHelperChip,
            onChipSelected: viewModel.selectHelperChip,
          ),
          ChatInput(
            shouldSaveAsContext: state.isSaveMode,
            onSaveModeToggle: () => viewModel.onSaveModeToggle(),
            onSubmit: (ChatMessageDTO chatMessage) {
              if (chatMessage.message?.isNotEmpty == true) {
                context.push(
                  RouteNames.chat,
                  extra: {
                    'initialMessage': chatMessage,
                    'sessionIds': [chatMessage.sessionId],
                    'selectedDate': DateTime.now(),
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, HomeViewState state, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          $styles.insets.md, mq.padding.top, $styles.insets.md, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular($styles.insets.lg),
          bottomRight: Radius.circular($styles.insets.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircularIconButton(
                  icon: Icons.menu,
                  size: 48,
                  iconColor: $styles.colors.black,
                  backgroundColor: Colors.transparent,
                  onTap: () => print("Navigate to Detailed Analysis page")),
              GestureDetector(
                onTap: () => context.push(RouteNames.chatHistory),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: $styles.insets.sm),
                    Text(DateFormat.yMMMMd().format(DateTime.now()),
                        style: $styles.text.bodySmall),
                  ],
                ),
              ),
              CircularIconButton(
                  size: 48,
                  icon: Icons.settings,
                  iconColor: $styles.colors.black,
                  backgroundColor: Colors.transparent,
                  onTap: () => context.go(RouteNames.settings)),
            ],
          ),
          SizedBox(height: $styles.insets.md),
          Text("Overall Score", style: $styles.text.h3),
          SizedBox(height: $styles.insets.md),
          TappableScore(
            score: state.bodySimulatorState?.healthScore.overallScore ?? 0,
            onTap: () => ref
                .read(homeViewModelProvider.notifier)
                .showBodySimulatorSnapshotDetails(context),
          ),
          SizedBox(height: $styles.insets.md),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: $styles.colors.greyStrong.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: $styles.text.caption,
      ),
    );
  }
}
