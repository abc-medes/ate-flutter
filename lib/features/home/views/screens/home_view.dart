import 'package:intl/intl.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/core/widgets/chat_input.dart';
import 'package:regene/core/widgets/circular_icon_button.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/features/home/view_models/home_view_model.dart';
import 'package:regene/features/home/views/widgets/chat_helper.dart';
import 'package:regene/features/home/views/widgets/tappable_score.dart';

// --- Main HomeView Widget ---
// Converted to ConsumerStatefulWidget to manage FocusNode
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _currentPage = 0; // State variable to track current page

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, state, ref),
                  SizedBox(height: $styles.insets.lg),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: $styles.insets.md),
                    child: Text("오늘의 인사이트", style: $styles.text.h3),
                  ),
                  SizedBox(height: $styles.insets.sm),
                  _buildInsightsList(),
                  SizedBox(height: $styles.insets.xl),
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
      padding: EdgeInsets.fromLTRB($styles.insets.md, mq.padding.top,
          $styles.insets.md, $styles.insets.md),
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

  Widget _buildInsightsList() {
    final state = ref.watch(homeViewModelProvider);

    final insights = state.insights;

    if (insights.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
        child: Text(
          '인사이트를 불러오는 중입니다...',
          style: $styles.text.bodySmall.copyWith(
            color: $styles.colors.caption,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            itemCount: insights.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
                child: _buildInsightCard(
                  insight.iconData,
                  insight.title,
                  insight.value,
                  insight.advice,
                ),
              );
            },
          ),
        ),
        SizedBox(height: $styles.insets.sm),
        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            insights.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentPage
                    ? $styles.colors.accent1
                    : $styles.colors.greyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
      IconData icon, String title, String value, String advice) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all($styles.insets.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: $styles.colors.accent1),
                SizedBox(width: $styles.insets.sm),
                Expanded(
                  child: Text(
                    title,
                    style: $styles.text.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: $styles.text.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: $styles.colors.accent1,
                  ),
                ),
              ],
            ),
            SizedBox(height: $styles.insets.sm),
            Text(
              advice,
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.body,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCardSkeleton() {
    return Card(
      elevation: 8,
      shadowColor: $styles.colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($styles.corners.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all($styles.insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Add this
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: $styles.colors.greyMedium,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: $styles.insets.md),
                Expanded(
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: $styles.colors.greyMedium,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: $styles.colors.greyMedium,
                    borderRadius: BorderRadius.circular($styles.corners.sm),
                  ),
                ),
              ],
            ),
            SizedBox(height: $styles.insets.lg),
            // Remove Expanded and use simple containers
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                3,
                (index) => Container(
                  width: double.infinity,
                  height: 16,
                  margin: EdgeInsets.only(bottom: index < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: $styles.colors.greyMedium,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
