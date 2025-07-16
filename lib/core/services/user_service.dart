import 'package:regene/common_libs.dart';
import 'package:regene/data/models/body_simulator_model.dart';
import 'package:regene/data/models/health_model.dart';
import 'package:regene/data/repositories/health_repository.dart';
import 'package:regene/data/models/user_model.dart' as um;

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

  Future<SBBodySimulatorStateSnapshot> bodySimulatorState() async {
    final response = await _client
        .from('user_body_state_snapshots')
        .select('*')
        .eq('user_id', _client.auth.currentUser!.id)
        .single();
    return SBBodySimulatorStateSnapshot.fromJson(response);
  }

  Stream<SBBodySimulatorStateSnapshot?> bodySimulatorStateStream(
      String userId) {
    return _client
        .from('user_body_state_snapshots') // just the table name
        .stream(primaryKey: ['id']) // enable realtime
        .eq('user_id', userId) // <- filter separately
        .limit(1)
        .map((rows) => rows.isEmpty
            ? null
            : SBBodySimulatorStateSnapshot.fromJson(rows.first));
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final service = UserService();
  service.initialize();
  return service;
});
