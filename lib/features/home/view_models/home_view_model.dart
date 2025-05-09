import 'package:ate_project/core/constants/ai_messages.dart';
import 'package:ate_project/core/services/api_service.dart';
import 'package:ate_project/core/widgets/%5Bdeprecated%5D_ai_response_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/data/repositories/health_repository.dart';
import 'package:ate_project/data/models/health_model.dart';

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final authService = ref.watch(authProvider).isAuthenticated;
  return HomeViewModel(authService);
});

class HomeViewState {
  final List<BasicUserData> missingBasicData;
  final List<ChatMessage> messages;
  final bool isProcessing;

  HomeViewState({
    this.missingBasicData = const [],
    this.messages = const [],
    this.isProcessing = false,
  });

  HomeViewState copyWith({
    bool? showLoginPrompt,
    List<BasicUserData>? missingBasicData,
    List<ChatMessage>? messages,
    bool? isProcessing,
  }) {
    return HomeViewState(
      missingBasicData: missingBasicData ?? this.missingBasicData,
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeViewState> {
  final bool _isAuthenticated;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode chatFocusNode = FocusNode();

  HomeViewModel(this._isAuthenticated) : super(HomeViewState()) {
    _init();

    // Add listener to textController to scroll when text changes
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

  void _init() async {
    await _checkMissingHealthData();
  }

  Future<void> _checkMissingHealthData() async {
    final missingFields = await HealthRepository().getMissingBasicUserData();
    state = state.copyWith(missingBasicData: missingFields);
  }

  void handleSubmit() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true);

    if (!_isAuthenticated) {
      state = state.copyWith(showLoginPrompt: true);
      return;
    }

    final updatedMessages = [
      ...state.messages,
      ChatMessage(text: text, isUser: true)
    ];
    state = state.copyWith(messages: updatedMessages);
    textController.clear();

    try {
      final response = await ApiService().sendChatMessage(text);

      final aiMessage = ChatMessage(
        text:
            response['response'] ?? 'Sorry, I could not process your request.',
        isUser: false,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isProcessing: false,
      );

      // Scroll to bottom after response
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // Handle error
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

  void handleMemorize() async {
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
      final response = await ApiService().memorizeChat(text);

      final aiMessage = ChatMessage(
        text:
            response['response'] ?? 'Sorry, I could not process your request.',
        isUser: false,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isProcessing: false,
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
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
