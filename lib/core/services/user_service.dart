import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/health_model.dart';
import 'package:bodido/data/models/insight_model.dart';
import 'package:bodido/data/models/profiles/user_model.dart' as um;
import 'package:bodido/data/repositories/health_repository.dart';

class UserService {
  final SupabaseClient _client = Supabase.instance.client;
  final _healthRepository = healthRepository;
  List<BasicUserData> _missingBasicUserData = [];
  bool _initialized = false;
  late um.User _user;

  List<BasicUserData> get missingBasicUserData => _missingBasicUserData;
  bool get isBasicHealthDataComplete => _missingBasicUserData.isEmpty;
  bool get isInitialized => _initialized;
  String get userId => _client.auth.currentUser!.id;
  um.User get user => _user;

  Future<void> initialize() async {
    await refreshBasicHealthData();
    await _getHealthMetricsFromDatabase(userId);
    await refreshUserProfile();
    _initialized = true;
  }

  Future<void> refreshUserProfile() async {
    _user = um.User.fromJson(await fetchUserProfile(userId));
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
    return Map<String, dynamic>.from(res['open_state']);
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

  /// ------------------------------End of App-open logic--------------

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

  Future<Map<String, dynamic>?> _getHealthMetricsFromDatabase(
      String userId) async {
    if (userId.isEmpty) {
      return null;
    }

    try {
      final response = await _client
          .from('health_metrics')
          .select('health_metrics')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null && response['health_metrics'] != null) {
        final healthMetrics =
            HealthMetrics.fromJson(response['health_metrics']);
        await _healthRepository.saveHealthMetricsToStorage(healthMetrics);
      }

      return null;
    } catch (e) {
      print('Error getting health metrics from database: $e');
      return null;
    }
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

  // ------------------------------------------------------------
  ///                       Insights
  // ------------------------------------------------------------
  Future<List<InsightItem>> getCurrentInsights(String userId) async {
    try {
      final row = await _client
          .from('personal_insights')
          .select('insights')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row == null || row['insights'] == null) return [];

      final raw = row['insights'];
      if (raw is! List) return []; // jsonb 배열이면 List<dynamic> 로 옴

      return raw
          .map((e) => InsightItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<InsightItem>> getInsightsWithFallback(String userId) async {
    final insights = await getCurrentInsights(userId);

    if (insights.isNotEmpty) {
      return insights;
    }

    return [];
  }

  // ------------------------------------------------------------
  ///                       Health Metrics
  // ------------------------------------------------------------
}

final userServiceProvider = Provider<UserService>((ref) {
  final service = UserService();
  final authed = ref.watch(isAuthedProvider);
  if (authed) {
    service.initialize();
  }
  return service;
});
