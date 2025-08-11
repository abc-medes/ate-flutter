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
                    'sessionId': chatMessage.sessionId,
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
    final insights = [
      {
        'icon': Icons.local_fire_department_outlined,
        'title': '염증 지수',
        'value': '높음',
        'advice': '항염증 식품을 섭취하고 충분한 휴식을 취하세요.'
      },
      {
        'icon': Icons.sentiment_very_dissatisfied_outlined,
        'title': '스트레스',
        'value': '나쁨',
        'advice': '명상이나 가벼운 운동으로 스트레스를 관리해보세요.'
      },
      {
        'icon': Icons.directions_run_outlined,
        'title': '다이어트 효율',
        'value': '보통',
        'advice': '식단에 단백질을 늘리고 규칙적인 운동을 시작해보세요.'
      },
      {
        'icon': Icons.shield_outlined,
        'title': '해독 능력',
        'value': '좋음',
        'advice': '몸의 해독 기능이 원활해요. 건강한 식단을 유지하세요.'
      },
      {
        'icon': Icons.nightlight_round_outlined,
        'title': '수면의 질',
        'value': '매우 나쁨',
        'advice': '자기 전 스마트폰 사용을 줄이고 일정한 시간에 잠자리에 들어보세요.'
      },
      {
        'icon': Icons.psychology_outlined,
        'title': '집중력 & 기분',
        'value': '양호',
        'advice': '집중력과 기분이 좋은 상태입니다. 꾸준히 유지하세요.'
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
      child: Column(
        children: insights.map((insight) {
          return _buildInsightCard(
            insight['icon'] as IconData,
            insight['title'] as String,
            insight['value'] as String,
            insight['advice'] as String,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightCard(
      IconData icon, String title, String value, String advice) {
    return Card(
      margin: EdgeInsets.only(bottom: $styles.insets.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($styles.corners.lg),
      ),
      elevation: 0,
      color: $styles.colors.background,
      child: Padding(
        padding: EdgeInsets.all($styles.insets.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: $styles.colors.accent1),
                SizedBox(width: $styles.insets.sm),
                Text(title, style: $styles.text.bodySmall),
                const Spacer(),
                Text(value,
                    style: $styles.text.h3.copyWith(
                      fontSize: 18,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            SizedBox(height: $styles.insets.sm),
            Text(advice,
                style: $styles.text.bodySmall
                    .copyWith(color: $styles.colors.black)),
          ],
        ),
      ),
    );
  }
}
