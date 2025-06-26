import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/services/api_service.dart';
// import 'package:ate_project/theme/app_theme.dart';
// import 'package:ate_project/core/widgets/%5Bdeprecated%5D_ai_response_bottom_sheet.dart';
import 'package:ate_project/data/models/chat_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/data/models/health_model.dart';

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final authService = ref.watch(authServiceProvider).isAuthenticated;
  return HomeViewModel(authService);
});

class HomeViewState {
  final List<BasicUserData> missingBasicData;
  final List<ChatMessage> messages;
  final bool isProcessing;
  final bool isSaveMode;
  HomeViewState({
    this.missingBasicData = const [],
    this.messages = const [],
    this.isProcessing = false,
    this.isSaveMode = false,
  });

  HomeViewState copyWith({
    bool? showLoginPrompt,
    List<BasicUserData>? missingBasicData,
    List<ChatMessage>? messages,
    bool? isProcessing,
    bool? isSaveMode,
  }) {
    return HomeViewState(
      missingBasicData: missingBasicData ?? this.missingBasicData,
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      isSaveMode: isSaveMode ?? this.isSaveMode,
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

  HomeViewModel(this._isAuthenticated) : super(HomeViewState()) {
    // _init();
    textController.addListener(_onTextChange);
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChange);
    textController.dispose();
    scrollController.dispose();
    chatFocusNode.dispose();
    super.dispose();
  }

  // Listen for text changes and scroll to bottom
  void _onTextChange() {
    if (textController.text.isNotEmpty) {
      scrollToBottom();
    }
  }

  void onSaveModeToggle() {
    state = state.copyWith(isSaveMode: !state.isSaveMode);
  }

  // Public method to scroll to bottom of chat
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
      final response = await ApiService.memorizeChat(text);

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

  void dismissLoginPrompt() {
    state = state.copyWith(showLoginPrompt: false);
  }

  void scrollUserMessageToTop() {
    final context = _userCurrentMessageKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.0, // 0.0 = 위쪽
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Health data helper methods
  List<DailyUserData> getDailyUserDataFields() {
    return DailyUserData.values;
  }

  String getHealthFieldName(BasicUserData field) {
    switch (field) {
      case BasicUserData.height:
        return 'Height';
      case BasicUserData.weight:
        return 'Weight';
      case BasicUserData.dateOfBirth:
        return 'Date of Birth';
      case BasicUserData.gender:
        return 'Gender';
      // case BasicUserData.preExistingConditions:
      //   return 'Health Conditions';
      // case BasicUserData.medications:
      //   return 'Medications';
      // case BasicUserData.allergies:
      //   return 'Allergies';
    }
  }

  IconData getHealthFieldIcon(BasicUserData field) {
    switch (field) {
      case BasicUserData.height:
        return Icons.height;
      case BasicUserData.weight:
        return Icons.monitor_weight;
      case BasicUserData.dateOfBirth:
        return Icons.cake;
      case BasicUserData.gender:
        return Icons.person;
      // case BasicUserData.preExistingConditions:
      //   return Icons.medical_information;
      // case BasicUserData.medications:
      //   return Icons.medication;
      // case BasicUserData.allergies:
      //   return Icons.coronavirus;
    }
  }

  String getDailyDataName(DailyUserData field) {
    switch (field) {
      case DailyUserData.nutritionData:
        return 'Nutrition';
      case DailyUserData.moodData:
        return 'Mood';
      case DailyUserData.symptoms:
        return 'Symptoms';
      case DailyUserData.sleepQuality:
        return 'Sleep';
      case DailyUserData.activityData:
        return 'Activity';
    }
  }

  IconData getDailyDataIcon(DailyUserData field) {
    switch (field) {
      case DailyUserData.nutritionData:
        return Icons.restaurant_menu;
      case DailyUserData.moodData:
        return Icons.mood;
      case DailyUserData.symptoms:
        return Icons.healing;
      case DailyUserData.sleepQuality:
        return Icons.nightlight_round;
      case DailyUserData.activityData:
        return Icons.directions_run;
    }
  }

  Color getDailyDataColor(DailyUserData field) {
    switch (field) {
      case DailyUserData.nutritionData:
        return Colors.green; // Replace with AppColors.nutrition
      case DailyUserData.moodData:
        return Colors.amber; // Replace with AppColors.mood
      case DailyUserData.symptoms:
        return Colors.redAccent;
      case DailyUserData.sleepQuality:
        return Colors.indigo; // Replace with AppColors.sleep
      case DailyUserData.activityData:
        return Colors.blue; // Replace with AppColors.activity
    }
  }
}
