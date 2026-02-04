import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/core/services/onboarding_complete_service.dart';
import 'package:bodido/core/services/onboarding_service.dart';
import 'package:bodido/data/models/health_model.dart';
import 'package:bodido/data/repositories/health_repository.dart';
import 'package:bodido/features/onboarding/views/widgets/body_type_pidcker.dart';
import 'package:bodido/features/onboarding/views/widgets/gender_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final String? error;

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
    this.error,
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
    String? error,
    bool clearError = false,
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
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HealthOnboardingViewModel extends StateNotifier<HealthOnboardingState> {
  final HealthRepository _healthRepository;
  final Ref ref;

  HealthOnboardingViewModel(this._healthRepository, this.ref)
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

      // await _userService.refreshBasicHealthData();

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

      // await _userService.refreshBasicHealthData();

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
      // await _userService.refreshBasicHealthData();

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

  void clearProgressMessages() {
    state = state.copyWith(progressMessages: []);
  }

  void _log(String message) {
    state = state.copyWith(
      progressMessages: [...state.progressMessages, message],
    );
  }

  Future<bool> finalizeOnboarding() async {
    state = state.copyWith(isFinalizing: true, clearError: true);
    try {
      _log('Saving your profile...');

      final authService = ref.read(authServiceProvider);
      await authService.ensureProfileAndEmptyHealthMetrics();

      final healthMetrics = await _healthRepository.getExistingHealthMetrics();
      _log('Uploading health metrics...');
      await OnboardingService().saveHealthMetricsToDatabase(healthMetrics);

      _log('Finishing...');
      await _healthRepository.saveOnboardingComplete();
      ref.invalidate(onboardingCompleteProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to complete setup. Please try again.',
      );
      return false;
    } finally {
      state = state.copyWith(isFinalizing: false);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final healthOnboardingProvider =
    StateNotifierProvider<HealthOnboardingViewModel, HealthOnboardingState>(
        (ref) {
  return HealthOnboardingViewModel(HealthRepository(), ref);
});
