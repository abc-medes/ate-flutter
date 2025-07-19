import 'package:regene/common_libs.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/core/widgets/chat_input.dart';
import 'package:regene/core/widgets/circular_icon_button.dart';
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
                children: [
                  _buildHeader(context, state, ref),
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
            onSubmit: (text, images) {
              if (text.isNotEmpty) {
                context.go(RouteNames.chat, extra: text);
                viewModel.textController.text = text;
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
              Row(
                children: [
                  Icon(Icons.calendar_month),
                  SizedBox(width: $styles.insets.sm),
                  Text("SAT, 25 JUN 2025", style: $styles.text.bodySmall),
                ],
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
            score: state.bodySimulatorState?.overallScore.overallScore ?? 0,
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
