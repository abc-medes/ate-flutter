import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/core/services/user_service.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/health_model.dart';
import 'package:bodido/data/models/insight_model.dart';
import 'package:bodido/features/home/views/widgets/_body_simultor_snapshot_details.dart';
import 'package:flutter/cupertino.dart';

enum ChatHelperType { ai, alerts, waitlist, system, context }

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final authService = ref.watch(authServiceProvider).isAuthenticated;
  final viewModel = HomeViewModel(authService);

  // Initialize both body state and insights
  viewModel.fetchBodySimulatorState(ref);

  return viewModel;
});

class HomeViewState {
  final List<BasicUserData> missingBasicData;
  final bool isProcessing;
  final bool isSaveMode;
  final ChatHelperType selectedHelperChip;
  final BodySimulatorStateSnapshotDTO? bodySimulatorState;
  final List<InsightItem> insights;
  final bool isLoadingInsights;

  HomeViewState({
    this.missingBasicData = const [],
    this.isProcessing = false,
    this.isSaveMode = false,
    this.selectedHelperChip = ChatHelperType.ai,
    this.bodySimulatorState,
    this.insights = const [], // Ensure this is never null
    this.isLoadingInsights = false,
  });

  HomeViewState copyWith({
    bool? showLoginPrompt,
    List<BasicUserData>? missingBasicData,
    bool? isProcessing,
    bool? isSaveMode,
    ChatHelperType? selectedHelperChip,
    BodySimulatorStateSnapshotDTO? bodySimulatorState,
    List<InsightItem>? insights,
    bool? isLoadingInsights,
  }) {
    return HomeViewState(
      missingBasicData: missingBasicData ?? this.missingBasicData,
      isProcessing: isProcessing ?? this.isProcessing,
      selectedHelperChip: selectedHelperChip ?? this.selectedHelperChip,
      bodySimulatorState: bodySimulatorState ?? this.bodySimulatorState,
      insights: insights ?? this.insights,
      isLoadingInsights: isLoadingInsights ?? this.isLoadingInsights,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeViewState> {
  final bool _isAuthenticated;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode chatFocusNode = FocusNode();
  final GlobalKey _userCurrentMessageKey = GlobalKey();
  GlobalKey get userCurrentMessageKey => _userCurrentMessageKey;

  HomeViewModel(this._isAuthenticated) : super(HomeViewState());

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    chatFocusNode.dispose();
    super.dispose();
  }

  void onSaveModeToggle() {
    state = state.copyWith(isSaveMode: !state.isSaveMode);
  }

  void selectHelperChip(ChatHelperType chipType) {
    if (state.selectedHelperChip == chipType) {
      return;
    } else {
      state = state.copyWith(selectedHelperChip: chipType);
    }
  }

  void showBodySimulatorSnapshotDetails(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => BodySimulatorSnapshotDetails(
        userId: state.bodySimulatorState!.userId,
        insights: state.insights,
      ),
    );
  }

  void fetchBodySimulatorState(Ref ref) async {
    final bodySimulatorState =
        await ref.read(userServiceProvider).bodySimulatorState();
    state = state.copyWith(bodySimulatorState: bodySimulatorState);

    await fetchInsights(ref);
  }

  Future<void> fetchInsights(Ref ref) async {
    if (state.isLoadingInsights) return;

    state = state.copyWith(isLoadingInsights: true);

    try {
      final userId = ref.read(userServiceProvider).userId;
      final insights =
          await ref.read(userServiceProvider).getInsightsWithFallback(userId);

      state = state.copyWith(
        insights: insights,
        isLoadingInsights: false,
      );
    } catch (e) {
      print('Error fetching insights: $e');
      state = state.copyWith(isLoadingInsights: false);
    }
  }
}
