import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/data/models/health_model.dart';
import 'package:ate_project/data/repositories/health_repository.dart';
import 'package:ate_project/core/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthOnboardingState {
  final int selectedHeight;
  final int selectedWeight;
  final DateTime selectedBirthDate;
  final bool isSaving;

  HealthOnboardingState({
    this.selectedHeight = 170,
    this.selectedWeight = 70,
    DateTime? selectedBirthDate,
    this.isSaving = false,
  }) : selectedBirthDate = selectedBirthDate ??
            DateTime.now().subtract(const Duration(days: 365 * 30));

  HealthOnboardingState copyWith({
    int? selectedHeight,
    int? selectedWeight,
    DateTime? selectedBirthDate,
    bool? isSaving,
  }) {
    return HealthOnboardingState(
      selectedHeight: selectedHeight ?? this.selectedHeight,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      selectedBirthDate: selectedBirthDate ?? this.selectedBirthDate,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class HealthOnboardingViewModel extends StateNotifier<HealthOnboardingState> {
  final HealthRepository _healthRepository;
  final UserService _userService;

  HealthOnboardingViewModel(this._healthRepository, this._userService)
      : super(HealthOnboardingState());

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

  Future<List<BasicUserData>> getMissingHealthData() async {
    return await _healthRepository.getMissingBasicUserData();
  }
}

final healthOnboardingProvider =
    StateNotifierProvider<HealthOnboardingViewModel, HealthOnboardingState>(
        (ref) {
  final userService = ref.watch(userServiceProvider);
  return HealthOnboardingViewModel(HealthRepository(), userService);
});
