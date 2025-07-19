import 'package:flutter/cupertino.dart';
import 'package:regene/common_libs.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/core/services/user_service.dart';
import 'package:regene/data/models/body_simulator_model.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/core/services/auth_service.dart';
import 'package:regene/data/models/health_model.dart';
import 'package:regene/features/home/views/widgets/_body_simultor_snapshot_details.dart';
import 'package:regene/features/home/views/widgets/system_detail_sheet.dart';

enum ChatHelperType { ai, alerts, waitlist, system, context }

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final authService = ref.watch(authServiceProvider).isAuthenticated;
  return HomeViewModel(authService)..fetchBodySimulatorState(ref);
});

class HomeViewState {
  final List<BasicUserData> missingBasicData;
  final List<ChatMessage> messages;
  final bool isProcessing;
  final bool isSaveMode;
  final ChatHelperType selectedHelperChip;
  final SBBodySimulatorStateSnapshot? bodySimulatorState;
  HomeViewState({
    this.missingBasicData = const [],
    this.messages = const [],
    this.isProcessing = false,
    this.isSaveMode = false,
    this.selectedHelperChip = ChatHelperType.ai,
    this.bodySimulatorState,
  });

  HomeViewState copyWith({
    bool? showLoginPrompt,
    List<BasicUserData>? missingBasicData,
    List<ChatMessage>? messages,
    bool? isProcessing,
    bool? isSaveMode,
    ChatHelperType? selectedHelperChip,
    SBBodySimulatorStateSnapshot? bodySimulatorState,
  }) {
    return HomeViewState(
      missingBasicData: missingBasicData ?? this.missingBasicData,
      messages: messages ?? this.messages,
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

  void scrollToBottom() {
    // Use a small delay to ensure layout is complete
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void handleChatSubmit() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true);

    final userMessage = ChatMessage(text: text, isUser: true);
    state = state.copyWith(messages: [...state.messages, userMessage]);
    textController.clear();

    final aiMessagePlaceholder = ChatMessage(text: '', isUser: false);
    state = state.copyWith(messages: [...state.messages, aiMessagePlaceholder]);

    final aiMessageIndex = state.messages.length - 1;

    try {
      final stream = ApiService.sendChatMessage(text);
      StringBuffer bufferedResponse = StringBuffer();

      await for (final chunk in stream) {
        bufferedResponse.write(chunk);
        final updatedAIMessage = state.messages[aiMessageIndex]
            .copyWith(text: bufferedResponse.toString());

        final newMessages = List<ChatMessage>.from(state.messages);
        newMessages[aiMessageIndex] = updatedAIMessage;
        state = state.copyWith(messages: newMessages);
        scrollToBottom();
      }

      state = state.copyWith(isProcessing: false);
    } catch (e) {
      final errorMessageText =
          'Sorry, there was an error: ${e.toString().replaceFirst("Exception: ", "")}';

      if (aiMessageIndex < state.messages.length &&
          state.messages[aiMessageIndex] == aiMessagePlaceholder) {
        final updatedAIMessage =
            state.messages[aiMessageIndex].copyWith(text: errorMessageText);
        final newMessages = List<ChatMessage>.from(state.messages);
        newMessages[aiMessageIndex] = updatedAIMessage;
        state = state.copyWith(
          messages: newMessages,
          isProcessing: false,
        );
      } else {
        final errorChatMessage =
            ChatMessage(text: errorMessageText, isUser: false);
        state = state.copyWith(
          messages: [...state.messages, errorChatMessage],
          isProcessing: false,
        );
      }
      scrollToBottom();
    }
  }

  void handleMemorize(BuildContext context) async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true);

    if (!_isAuthenticated) {
      state = state.copyWith(showLoginPrompt: true);
      return;
    }

    textController.clear();

    try {
      // final response = await ApiService.memorizeChat(text);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // SnackBar(
          //   content: const Text('Memory updated successfully'),
          //   action: SnackBarAction(
          //     label: 'View Memories',
          //     onPressed: () {
          //       // context.go(RouteNames.memories);
          //     },
          //   ),
          //   duration: const Duration(seconds: 3),
          //   behavior: SnackBarBehavior.floating,
          // ),
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.surface),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Memory updated successfully',
                    style: TextStyle(color: AppColors.surface),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(8),
          ),
        );
      }

      state = state.copyWith(
        isProcessing: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        text:
            'Sorry, there was an error processing your request. Please try again.',
        isUser: false,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isProcessing: false,
      );
    }
  }

  void fetchBodySimulatorState(Ref ref) async {
    final bodySimulatorState =
        await ref.read(userServiceProvider).bodySimulatorState();
    state = state.copyWith(bodySimulatorState: bodySimulatorState);
  }
}
