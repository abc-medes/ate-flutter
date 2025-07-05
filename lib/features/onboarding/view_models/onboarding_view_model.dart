import 'dart:convert';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/features/onboarding/views/widgets/gender_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regene/data/models/health_model.dart';
import 'package:regene/data/repositories/health_repository.dart';
import 'package:regene/core/services/user_service.dart';

class HealthOnboardingState {
  final int selectedHeight;
  final int selectedWeight;
  final DateTime selectedBirthDate;
  final Gender selectedGender;
  final bool isSaving;
  final int currentPage;

  HealthOnboardingState({
    this.selectedHeight = 170,
    this.selectedWeight = 70,
    DateTime? selectedBirthDate,
    this.selectedGender = Gender.male,
    this.isSaving = false,
    this.currentPage = 0,
  }) : selectedBirthDate = selectedBirthDate ??
            DateTime.now().subtract(const Duration(days: 365 * 30));

  HealthOnboardingState copyWith({
    int? selectedHeight,
    int? selectedWeight,
    DateTime? selectedBirthDate,
    Gender? selectedGender,
    bool? isSaving,
    int? currentPage,
  }) {
    return HealthOnboardingState(
      selectedHeight: selectedHeight ?? this.selectedHeight,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      selectedBirthDate: selectedBirthDate ?? this.selectedBirthDate,
      selectedGender: selectedGender ?? this.selectedGender,
      isSaving: isSaving ?? this.isSaving,
      currentPage: currentPage ?? this.currentPage,
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
}

final healthOnboardingProvider =
    StateNotifierProvider<HealthOnboardingViewModel, HealthOnboardingState>(
        (ref) {
  final userService = ref.watch(userServiceProvider);
  return HealthOnboardingViewModel(HealthRepository(), userService);
});
