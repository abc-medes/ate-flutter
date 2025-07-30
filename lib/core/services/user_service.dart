import 'package:regene/common_libs.dart';
import 'package:regene/data/models/body_simulator_model.dart';
import 'package:regene/data/models/health_model.dart';
import 'package:regene/data/repositories/health_repository.dart';
import 'package:regene/data/models/profiles/user_model.dart' as um;

class UserService {
  final SupabaseClient _client = Supabase.instance.client;
  final _healthRepository = healthRepository;
  List<BasicUserData> _missingBasicUserData = [];
  bool _initialized = false;

  List<BasicUserData> get missingBasicUserData => _missingBasicUserData;
  bool get isBasicHealthDataComplete => _missingBasicUserData.isEmpty;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    await refreshBasicHealthData();
    _initialized = true;
  }

  /// ------------------------------------------------------------
  ///                       App-open logic
  /// ------------------------------------------------------------
  /// Was the app ever opened before?

  Future<Map<String, dynamic>> _getOpenStateMap(String userId) async {
    final res = await _client
        .from('profiles')
        .select('open_state')
        .eq('id', userId)
        .single();
    return Map<String, dynamic>.from(res['open_state'] ?? {});
  }

  Future<void> _saveOpenStateMap(
      String userId, Map<String, dynamic> map) async {
    await _client.from('profiles').update({'open_state': map}).eq('id', userId);
  }

  Future<bool> hasUserOpenedApp(String userId) async {
    final map = await _getOpenStateMap(userId);
    return map['has_opened_app'] ?? false;
  }

  Future<bool> isAppOpen(String userId) async {
    final map = await _getOpenStateMap(userId);
    return map['is_app_open'] ?? false;
  }

  Future<void> setUserAppOpened(String userId) async {
    final map = await _getOpenStateMap(userId);
    map
      ..['has_opened_app'] = true
      ..['is_app_open'] = true
      ..['last_opened_at'] = DateTime.now().toIso8601String();
    await _saveOpenStateMap(userId, map);
  }

  /// Mark app as closed
  Future<void> setUserAppClosed(String userId) async {
    final map = await _getOpenStateMap(userId);
    map
      ..['is_app_open'] = false
      ..['last_closed_at'] = DateTime.now().toIso8601String();
    await _saveOpenStateMap(userId, map);
  }

  /// Realtime flag if you need to react to the current open/closed state.
  Stream<bool> isAppOpenStream(String userId) {
    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .limit(1)
        .map((rows) => rows.isEmpty
            ? false
            : (rows.first['open_state']?['is_app_open'] ?? false));
  }

  /// ------------------------------------------------------------

  /// Realtime stream to observe changes to the flag.
  Stream<bool> hasUserOpenedAppStream(String userId) {
    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .limit(1)
        .map(
          (rows) =>
              rows.isEmpty ? false : (rows.first['has_opened_app'] ?? false),
        );
  }

  Future<void> refreshBasicHealthData() async {
    _missingBasicUserData = await _healthRepository.getMissingBasicUserData();
  }

  Future<bool> isFieldComplete(BasicUserData field) async {
    return await _healthRepository.isBasicUserDataSaved(field);
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final response =
        await _client.from('profiles').select().eq('id', userId).single();

    return response;
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _client.from('profiles').update(data).eq('id', userId);
  }

  Future<void> createProfile({
    required String userId,
    required String email,
    required String name,
  }) async {
    final existingProfile = await _client
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    if (existingProfile != null) {
      final updatedUser = um.User.newUser(
        id: userId,
        email: email,
        name: name,
      );

      await _client
          .from('profiles')
          .update(updatedUser.toJson())
          .eq('id', userId);
    } else {
      final newUser = um.User.newUser(
        id: userId,
        email: email,
        name: name,
      );
      await _client.from('profiles').insert(newUser.toJson());
    }
  }

  Future<void> createEmptyUserHealthMetrics(String userId) async {
    final emptyHealthMetrics = HealthMetrics(
      userInputData: UserInputData(),
      autoDetectedData: AutoDetectedData(),
      environmentalData: EnvironmentalData(),
      bodySimulatorData: BodySimulatorState.empty(),
    );

    final now = DateTime.now();
    final healthData = {
      'user_id': userId,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'health_metrics': emptyHealthMetrics.toJson(),
    };

    await _client.from('health_metrics').insert(
          healthData,
        );
  }

  Future<BodySimulatorStateSnapshotDTO> bodySimulatorState() async {
    final response = await _client
        .from('user_body_state_snapshots')
        .select('*')
        .eq('user_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false)
        .limit(1)
        .single();
    return BodySimulatorStateSnapshotDTO.fromJson(response);
  }

  Stream<BodySimulatorStateSnapshotDTO?> bodySimulatorStateStream(
      String userId) {
    return _client
        .from('user_body_state_snapshots')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .map((rows) => rows.isEmpty
            ? null
            : BodySimulatorStateSnapshotDTO.fromJson(rows.first));
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final service = UserService();
  service.initialize();
  return service;
});
