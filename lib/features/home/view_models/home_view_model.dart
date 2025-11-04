import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/api_service.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/core/services/tracking_questions_service.dart';
import 'package:bodido/core/services/user_service.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/health_model.dart';
import 'package:bodido/data/models/insight_model.dart';
import 'package:bodido/data/models/tracking_question_model.dart';
import 'package:bodido/features/home/views/widgets/_body_simultor_snapshot_details.dart';
import 'package:flutter/cupertino.dart';

enum ChatHelperType { ai, alerts, waitlist, system, context }

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final authService = ref.watch(authServiceProvider).isAuthenticated;
  final viewModel = HomeViewModel(authService);

  viewModel.fetchBodySimulatorState(ref);
  viewModel.loadTrackingQuestions(ref);

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
  final List<TrackingQuestion> userQuestions;
  final bool isLoadingUserQuestions;
  final Map<String, String> selectedOptions;
  final bool isSavingSelections;

  HomeViewState({
    this.missingBasicData = const [],
    this.isProcessing = false,
    this.isSaveMode = false,
    this.selectedHelperChip = ChatHelperType.ai,
    this.bodySimulatorState,
    this.insights = const [],
    this.isLoadingInsights = false,
    this.userQuestions = const [],
    this.isLoadingUserQuestions = false,
    this.selectedOptions = const {},
    this.isSavingSelections = false,
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
    List<TrackingQuestion>? userQuestions,
    bool? isLoadingUserQuestions,
    Map<String, String>? selectedOptions,
    bool? isSavingSelections,
  }) {
    return HomeViewState(
      missingBasicData: missingBasicData ?? this.missingBasicData,
      isProcessing: isProcessing ?? this.isProcessing,
      isSaveMode: isSaveMode ?? this.isSaveMode,
      selectedHelperChip: selectedHelperChip ?? this.selectedHelperChip,
      bodySimulatorState: bodySimulatorState ?? this.bodySimulatorState,
      insights: insights ?? this.insights,
      isLoadingInsights: isLoadingInsights ?? this.isLoadingInsights,
      userQuestions: userQuestions ?? this.userQuestions,
      isLoadingUserQuestions:
          isLoadingUserQuestions ?? this.isLoadingUserQuestions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      isSavingSelections: isSavingSelections ?? this.isSavingSelections,
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

  // ------------------------------------------------------------
  ///                       Tracking Questions
  // ------------------------------------------------------------
  Future<void> loadTrackingQuestions(Ref ref) async {
    if (state.isLoadingUserQuestions) return;
    state = state.copyWith(isLoadingUserQuestions: true);
    try {
      final userId = ref.read(userServiceProvider).userId;
      final qs =
          await ref.read(trackingQuestionsServiceProvider).getPendingOrGenerate(
                userId: userId,
                language: 'ko',
                maxQuestions: '10',
                optionsPerQuestion: '3',
                goalFocus: 'general',
                trackingTargets: const {},
                limit: 20,
              );
      state = state.copyWith(
        userQuestions: qs,
        isLoadingUserQuestions: false,
      );
    } catch (e) {
      debugPrint('[HomeVM] loadTrackingQuestions error: $e');
      state = state.copyWith(isLoadingUserQuestions: false);
    }
  }

  void selectQuestionOptionLocal(TrackingQuestion q, QuestionOption opt) {
    final updated = Map<String, String>.from(state.selectedOptions)
      ..[q.id] = opt.id;
    state = state.copyWith(selectedOptions: updated);
  }

  Future<void> commitSelectedTrackingOptions() async {
    if (state.isSavingSelections || state.selectedOptions.isEmpty) return;
    state = state.copyWith(isSavingSelections: true);

    try {
      final questions = state.userQuestions;
      for (final entry in state.selectedOptions.entries) {
        final qId = entry.key;
        final optId = entry.value;

        final q = questions.firstWhere((x) => x.id == qId);
        final opt = q.options.firstWhere((o) => o.id == optId);

        final req = UserSelectionRequest(
          questionId: q.id,
          questionTag: q.questionTag,
          optionId: opt.id,
          selectionKey: opt.selectionKey,
          clientLocalTimestamp: DateTime.now(),
        );

        // Optional preview:
        // await ApiService.selectTrackingOption(request: req, dryRun: true);
        await ApiService.selectTrackingOption(request: req, dryRun: false);
      }

      state = state.copyWith(selectedOptions: {});
    } catch (e) {
      print('Error committing selections: $e');
    } finally {
      state = state.copyWith(isSavingSelections: false);
    }
  }
  // ------------------------------------------------------------
}
