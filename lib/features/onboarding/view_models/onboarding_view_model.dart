import 'package:bodai/core/services/api_service.dart';
import 'package:bodai/core/services/onboarding_service.dart';
import 'package:bodai/features/onboarding/views/widgets/body_type_pidcker.dart';
import 'package:bodai/features/onboarding/views/widgets/gender_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bodai/data/models/health_model.dart';
import 'package:bodai/data/repositories/health_repository.dart';
import 'package:bodai/core/services/user_service.dart';

class HealthOnboardingState {
  final int selectedHeight;
  final int selectedWeight;
  final DateTime selectedBirthDate;
  final Gender selectedGender;
  final BodyType selectedBodyType;
  final bool isSaving;
  final int currentPage;
  final List<String> progressMessages;
  final bool isFinalizing;

  HealthOnboardingState({
    this.selectedHeight = 170,
    this.selectedWeight = 70,
    DateTime? selectedBirthDate,
    this.selectedGender = Gender.male,
    this.selectedBodyType = BodyType.slim,
    this.isSaving = false,
    this.currentPage = 0,
    this.progressMessages = const [],
    this.isFinalizing = false,
  }) : selectedBirthDate = selectedBirthDate ??
            DateTime.now().subtract(const Duration(days: 365 * 30));

  HealthOnboardingState copyWith({
    int? selectedHeight,
    int? selectedWeight,
    DateTime? selectedBirthDate,
    Gender? selectedGender,
    BodyType? selectedBodyType,
    bool? isSaving,
    int? currentPage,
    List<String>? progressMessages,
    bool? isFinalizing,
  }) {
    return HealthOnboardingState(
      selectedHeight: selectedHeight ?? this.selectedHeight,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      selectedBirthDate: selectedBirthDate ?? this.selectedBirthDate,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedBodyType: selectedBodyType ?? this.selectedBodyType,
      isSaving: isSaving ?? this.isSaving,
      currentPage: currentPage ?? this.currentPage,
      progressMessages: progressMessages ?? this.progressMessages,
      isFinalizing: isFinalizing ?? this.isFinalizing,
    );
  }
}

class HealthOnboardingViewModel extends StateNotifier<HealthOnboardingState> {
  final HealthRepository _healthRepository;
  final UserService _userService;

  HealthOnboardingViewModel(this._healthRepository, this._userService)
      : super(HealthOnboardingState());

  void updateCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void updateHeight(int height) {
    state = state.copyWith(selectedHeight: height);
  }

  void updateWeight(int weight) {
    state = state.copyWith(selectedWeight: weight);
  }

  Future<bool> saveHeightandWeightData() async {
    state = state.copyWith(isSaving: true);

    try {
      await _healthRepository.saveHeightAndWeight(
          state.selectedHeight, state.selectedWeight);

      await _userService.refreshBasicHealthData();

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  void updateBirthDate(DateTime date) {
    state = state.copyWith(selectedBirthDate: date);
  }

  Future<bool> saveBirthDate() async {
    state = state.copyWith(isSaving: true);

    try {
      await _healthRepository.saveBirthDate(state.selectedBirthDate);

      await _userService.refreshBasicHealthData();

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  void updateGender(Gender gender) {
    state = state.copyWith(selectedGender: gender);
  }

  Future<bool> saveGender() async {
    state = state.copyWith(isSaving: true);

    try {
      await _healthRepository.saveGender(state.selectedGender);
      await _userService.refreshBasicHealthData();

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  void updateBodyType(BodyType bodyType) {
    state = state.copyWith(selectedBodyType: bodyType);
  }

  Future<bool> saveBodyType() async {
    state = state.copyWith(isSaving: true);
    try {
      await _healthRepository.saveBodyType(state.selectedBodyType);
      await _userService.refreshBasicHealthData();

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<List<BasicUserData>> getMissingHealthData() async {
    return await _healthRepository.getMissingBasicUserData();
  }

  Future<bool> initializeBodySimulatorState() async {
    state = state.copyWith(isSaving: true);
    try {
      await ApiService.initializeBodySimulatorState();
      return true;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void clearProgressMessages() {
    state = state.copyWith(progressMessages: []);
  }

  void _log(String message) {
    state = state.copyWith(
      progressMessages: [...state.progressMessages, message],
    );
  }

  Future<bool> finalizeOnboarding() async {
    state = state.copyWith(isFinalizing: true);
    try {
      final healthMetrics = await _healthRepository.getExistingHealthMetrics();
      await OnboardingService().saveHealthMetricsToDatabase(healthMetrics);
      _log('Saving health-metrics to database - done');
      await initializeBodySimulatorState();
      _log('Initializing body simulator state - done');

      return true;
    } catch (e) {
      print('Error finalising onboarding: $e');
      return false;
    } finally {
      state = state.copyWith(isFinalizing: false);
    }
  }
}

final healthOnboardingProvider =
    StateNotifierProvider<HealthOnboardingViewModel, HealthOnboardingState>(
        (ref) {
  final userService = ref.watch(userServiceProvider);
  return HealthOnboardingViewModel(HealthRepository(), userService);
});
