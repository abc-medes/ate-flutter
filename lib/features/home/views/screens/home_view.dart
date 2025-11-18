import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/chat_input.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';
import 'package:bodido/core/widgets/loading_view.dart';
import 'package:bodido/data/models/chat_model.dart';
// removed model imports (not directly referenced here)
import 'package:bodido/features/home/view_models/home_view_model.dart';
import 'package:intl/intl.dart';

// --- Main HomeView Widget ---
// Converted to ConsumerStatefulWidget to manage FocusNode
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  Future<void> _openQuestionsSheet(BuildContext context, WidgetRef ref) async {
    final state = ref.read(homeViewModelProvider);

    if (state.isLoadingUserQuestions) {
      LoadingScreen.show(context);
      return;
    }

    if (state.userQuestions.isEmpty && state.answeredQuestions.isEmpty) {
      LoadingScreen.show(context);
      await Future.delayed(const Duration(milliseconds: 500));
      final updatedState = ref.read(homeViewModelProvider);
      if (updatedState.isLoadingUserQuestions) {
        return; // Still loading, keep overlay
      }
      LoadingScreen.dismiss(context);
    }

    ref.read(homeViewModelProvider.notifier).showQuestionsSheet(context);
  }

  Future<void> _openScoreSheet(BuildContext context, WidgetRef ref) async {
    final state = ref.read(homeViewModelProvider);

    if (state.bodySimulatorState == null || state.isLoadingInsights) {
      LoadingScreen.show(context);
      return;
    }

    ref
        .read(homeViewModelProvider.notifier)
        .showBodySimulatorSnapshotDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final state = ref.watch(homeViewModelProvider);

    ref.listen<bool>(
      homeViewModelProvider
          .select((s) => s.isLoadingUserQuestions || s.isLoadingInsights),
      (prev, isLoading) {
        if (isLoading) {
          LoadingScreen.show(context);
        } else {
          LoadingScreen.dismiss(context);
        }
      },
    );

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          _buildHeader(context, state, ref),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  $styles.insets.md, 0, $styles.insets.md, $styles.insets.md),
              child: Column(
                children: [
                  Expanded(
                    child: _HomeBigButton(
                      icon: Icons.insights_outlined,
                      title: $strings.home_score,
                      subtitle: $strings.home_overall_score(
                          (state.bodySimulatorState?.healthScore.overallScore ??
                                  0)
                              .toStringAsFixed(1)),
                      gradientStart: $styles.colors.accent2,
                      gradientEnd: $styles.colors.accent1,
                      onTap: () => _openScoreSheet(context, ref),
                    ),
                  ),
                  SizedBox(height: $styles.insets.md),
                  Expanded(
                    child: _HomeBigButton(
                      icon: Icons.rule_folder_outlined,
                      title: $strings.home_questions,
                      subtitle: state.userQuestions.isEmpty
                          ? $strings.home_no_pending_questions
                          : $strings
                              .home_num_pending(state.userQuestions.length),
                      gradientStart: $styles.colors.accent1,
                      gradientEnd: $styles.colors.accent3,
                      onTap: () => _openQuestionsSheet(context, ref),
                    ),
                  ),
                  SizedBox(height: $styles.insets.md),
                  Expanded(
                    child: _HomeBigButton(
                      icon: Icons.chat_bubble_outline,
                      title: $strings.home_chat_history,
                      subtitle: $strings.home_chat_history_subtitle,
                      gradientStart: $styles.colors.accent3,
                      gradientEnd: $styles.colors.accent2,
                      onTap: () => context.push(RouteNames.chatHistory),
                    ),
                  ),
                ],
              ),
            ),
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
              Row(
                children: [
                  CircularIconButton(
                      size: 48,
                      icon: Icons.shopping_bag,
                      iconColor: $styles.colors.black,
                      backgroundColor: Colors.transparent,
                      onTap: () =>
                          context.go(RouteNames.productRecommendations)),
                  CircularIconButton(
                      size: 48,
                      icon: Icons.settings,
                      iconColor: $styles.colors.black,
                      backgroundColor: Colors.transparent,
                      onTap: () => context.go(RouteNames.settings)),
                ],
              ),
            ],
          ),
          SizedBox(height: $styles.insets.md),
        ],
      ),
    );
  }
}

// Big button widget used on Home to represent each section
class _HomeBigButton extends StatelessWidget {
  const _HomeBigButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular($styles.corners.md),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular($styles.corners.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientStart.withOpacity(0.24),
              gradientEnd.withOpacity(0.14),
            ],
          ),
          border: Border.all(color: gradientStart.withOpacity(0.30), width: 1),
          boxShadow: [
            BoxShadow(
              color: gradientStart.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          color: $styles.colors.backgroundDark,
        ),
        child: Padding(
          padding: EdgeInsets.all($styles.insets.md),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: gradientStart.withOpacity(0.20),
                  borderRadius: BorderRadius.circular($styles.corners.md),
                ),
                child: Icon(icon, color: gradientStart, size: 32),
              ),
              SizedBox(width: $styles.insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: $styles.text.bodyBold.copyWith(fontSize: 20)),
                    SizedBox(height: 4),
                    Text(subtitle,
                        style: $styles.text.caption
                            .copyWith(color: $styles.colors.caption)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: $styles.colors.caption, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// (Badge widget removed - not used)
