import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/api_service.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/core/services/onboarding_complete_service.dart';
import 'package:bodido/core/services/tracking_questions_service.dart';
import 'package:bodido/core/services/user_service.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/health_model.dart';
import 'package:bodido/data/models/insight_model.dart';
import 'package:bodido/data/models/tracking_question_model.dart';
import 'package:bodido/data/repositories/app_lifecycle_repository.dart';
import 'package:bodido/features/home/views/widgets/_body_simulator_snapshot_details.dart';
import 'package:bodido/features/home/views/widgets/_questions_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:bodido/core/utils/logger.dart';

enum ChatHelperType { ai, alerts, waitlist, system, context }

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final authService = ref.watch(authServiceProvider).isAuthenticated;
  final onboardingDone = ref.watch(onboardingCompleteProvider).value ?? false;

  if (!onboardingDone) {
    return HomeViewModel(authService);
  }
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
  final List<TrackingQuestion> answeredQuestions;
  final bool isLoadingUserQuestions;

  final Map<String, String> selectedOptions;
  final Map<String, String> answeredOptions;
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
    this.answeredQuestions = const [],
    this.isLoadingUserQuestions = false,
    this.selectedOptions = const {},
    this.answeredOptions = const {},
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
    List<TrackingQuestion>? answeredQuestions,
    bool? isLoadingUserQuestions,
    Map<String, String>? selectedOptions,
    Map<String, String>? answeredOptions,
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
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      isLoadingUserQuestions:
          isLoadingUserQuestions ?? this.isLoadingUserQuestions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      answeredOptions: answeredOptions ?? this.answeredOptions,
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

  void showQuestionsSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => QuestionsSheet(),
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
      AppLogger.error('Error fetching insights: $e');
      state = state.copyWith(isLoadingInsights: false);
    }
  }

  // ------------------------------------------------------------
  ///                       Tracking Questions
  // ------------------------------------------------------------
  Future<void> loadTrackingQuestions(Ref ref) async {
    if (state.isLoadingUserQuestions) return;

    final shouldRefresh = await ref
        .read(appLifecycleRepositoryProvider)
        .shouldRefreshQuestions(minInterval: const Duration(hours: 6));

    if (state.userQuestions.isNotEmpty && !shouldRefresh) return;

    state = state.copyWith(isLoadingUserQuestions: true);
    try {
      final svc = ref.read(trackingQuestionsServiceProvider);
      final userId = ref.read(userServiceProvider).userId;

      final pendingIds = await svc
          .listQuestionIds(userId, limit: 10, statuses: const ['pending']);
      final answeredIds = await svc
          .listQuestionIds(userId, limit: 10, statuses: const ['selected']);

      List<String> _uniqPreserveOrder(List<String> ids) {
        final seen = <String>{};
        final out = <String>[];
        for (final id in ids) {
          if (seen.add(id)) out.add(id);
        }
        return out;
      }

      final pendingUniq = _uniqPreserveOrder(pendingIds);
      final pendingSet = pendingUniq.toSet();

      final answeredUniq = <String>[];
      for (final id in answeredIds) {
        if (!pendingSet.contains(id) && !answeredUniq.contains(id)) {
          answeredUniq.add(id);
        }
      }

      final fetchedPending = pendingUniq.isNotEmpty
          ? await svc.getManyByIds(pendingUniq)
          : await ApiService.createTrackingQuestions(
              language: 'ko',
              maxQuestions: '10',
              optionsPerQuestion: '3',
              goalFocus: 'general',
              trackingTargets: const {},
            );

      final fetchedAnswered = answeredUniq.isNotEmpty
          ? await svc.getManyByIds(answeredUniq)
          : <TrackingQuestion>[];

      final answeredOptions = await svc.listSelectedOptionsMap(
        userId,
        questionIds: answeredUniq,
      );

      await ref.read(appLifecycleRepositoryProvider).markQuestionsRefreshed();

      state = state.copyWith(
        userQuestions: fetchedPending,
        answeredQuestions: fetchedAnswered,
        answeredOptions: answeredOptions,
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
      final committedIds = <String>{};

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

        await ApiService.selectTrackingOption(request: req, dryRun: false);
        committedIds.add(qId);
      }

      // Locally remove committed questions from pending UI
      final remaining = state.userQuestions
          .where((q) => !committedIds.contains(q.id))
          .toList();

      state = state.copyWith(
        userQuestions: remaining,
        selectedOptions: {},
      );
    } catch (e) {
      AppLogger.error('Error committing selections: $e');
    } finally {
      state = state.copyWith(isSavingSelections: false);
    }
  }
  // ------------------------------------------------------------
}
