import 'package:flutter/cupertino.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/core/services/user_service.dart';
import 'package:regene/data/models/body_simulator_model.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/core/services/auth_service.dart';
import 'package:regene/data/models/health_model.dart';
import 'package:regene/features/home/views/widgets/_body_simultor_snapshot_details.dart';

enum ChatHelperType { ai, alerts, waitlist, system, context }

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final authService = ref.watch(authServiceProvider).isAuthenticated;
  return HomeViewModel(authService)..fetchBodySimulatorState(ref);
});

class HomeViewState {
  final List<BasicUserData> missingBasicData;
  final bool isProcessing;
  final bool isSaveMode;
  final ChatHelperType selectedHelperChip;
  final BodySimulatorStateSnapshotDTO? bodySimulatorState;
  HomeViewState({
    this.missingBasicData = const [],
    this.isProcessing = false,
    this.isSaveMode = false,
    this.selectedHelperChip = ChatHelperType.ai,
    this.bodySimulatorState,
  });

  HomeViewState copyWith({
    bool? showLoginPrompt,
    List<BasicUserData>? missingBasicData,
    bool? isProcessing,
    bool? isSaveMode,
    ChatHelperType? selectedHelperChip,
    BodySimulatorStateSnapshotDTO? bodySimulatorState,
  }) {
    return HomeViewState(
      missingBasicData: missingBasicData ?? this.missingBasicData,
      isProcessing: isProcessing ?? this.isProcessing,
      isSaveMode: isSaveMode ?? this.isSaveMode,
      selectedHelperChip: selectedHelperChip ?? this.selectedHelperChip,
      bodySimulatorState: bodySimulatorState ?? this.bodySimulatorState,
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
      ),
    );
  }

  void fetchBodySimulatorState(Ref ref) async {
    final bodySimulatorState =
        await ref.read(userServiceProvider).bodySimulatorState();
    state = state.copyWith(bodySimulatorState: bodySimulatorState);
  }
}
