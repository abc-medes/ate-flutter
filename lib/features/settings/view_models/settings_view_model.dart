import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bodai/core/services/user_service.dart';
import 'package:bodai/data/models/health_model.dart';
import 'package:bodai/data/models/profiles/_ai_settings.dart';
import 'package:bodai/data/repositories/health_repository.dart';

class SettingsState {
  final Map<String, dynamic>? healthContext;
  final Map<String, dynamic>? memorizedData;
  final AISettings? aiSettings;

  const SettingsState({
    this.healthContext,
    this.memorizedData,
    this.aiSettings,
  });

  SettingsState copyWith({
    Map<String, dynamic>? healthContext,
    Map<String, dynamic>? memorizedData,
    AISettings? aiSettings,
  }) {
    return SettingsState(
      healthContext: healthContext ?? this.healthContext,
      memorizedData: memorizedData ?? this.memorizedData,
      aiSettings: aiSettings ?? this.aiSettings,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  final UserService _userService;

  SettingsViewModel(this._userService) : super(const SettingsState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    final metrics = await healthRepository.getExistingHealthMetrics();
    final mem = metrics.userInputData.memorizedData;
    final hc = mem != null && mem['health_context'] != null
        ? Map<String, dynamic>.from(mem['health_context'])
        : null;

    final uid = _userService.userId;
    final profile = await _userService.fetchUserProfile(uid);
    final prefs = Map<String, dynamic>.from(profile['preferences'] ?? {});
    final aiJson = Map<String, dynamic>.from(prefs['ai_settings'] ?? {});
    final ai = AISettings.fromJson(aiJson);

    state = state.copyWith(
        healthContext: hc,
        memorizedData: mem != null ? Map<String, dynamic>.from(mem) : null,
        aiSettings: ai);
  }

  Future<void> setHealthContextFromRaw(Map<String, dynamic> raw) async {
    final updated = raw['updated_value'];

    print('updated: $updated');

    final memorizedData = UserInputData.fromJson(
            Map<String, dynamic>.from(updated['user_input_data']))
        .memorizedData;

    print('memorizedData: $memorizedData');

    state = state.copyWith(memorizedData: memorizedData);
  }

  Future<void> setAISettingsFromRaw(Map<String, dynamic> raw) async {
    if (raw['path'] != 'ai_settings') return;
    final updated = raw['updated_value'];
    if (updated is! Map<String, dynamic>) return;

    final ai = AISettings.fromJson(Map<String, dynamic>.from(updated));
    state = state.copyWith(aiSettings: ai);
  }
}

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>(
  (ref) => SettingsViewModel(ref.read(userServiceProvider)),
);
