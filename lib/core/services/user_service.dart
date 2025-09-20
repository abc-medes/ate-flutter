import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/health_model.dart';
import 'package:bodido/data/models/insight_model.dart';
import 'package:bodido/data/repositories/health_repository.dart';
import 'package:bodido/data/models/profiles/user_model.dart' as um;

class UserService {
  final SupabaseClient _client = Supabase.instance.client;
  final _healthRepository = healthRepository;
  List<BasicUserData> _missingBasicUserData = [];
  bool _initialized = false;
  um.User? _user;

  List<BasicUserData> get missingBasicUserData => _missingBasicUserData;
  bool get isBasicHealthDataComplete => _missingBasicUserData.isEmpty;
  bool get isInitialized => _initialized;
  String get userId => _client.auth.currentUser?.id ?? '';
  um.User? get user => _user;

  Future<void> initialize() async {
    await refreshBasicHealthData();
    await _getHealthMetricsFromDatabase(userId);

    _initialized = true;
  }

  Future<void> _fetchUserProfile() async {
    try {
      if (_client.auth.currentUser != null) {
        final profileData =
            await fetchUserProfile(_client.auth.currentUser!.id);
        _user = um.User.fromJson(profileData);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      _user = null;
    }
  }

  Future<void> refreshUserProfile() async {
    await _fetchUserProfile();
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
      final response = await _client
          .from('personal_insights')
          .select('insights')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null || response['insights'] == null) {
        print('[Insights] No previous insights for user=$userId');
        return [];
      }

      final insightsData = response['insights'] as List<dynamic>;
      return insightsData
          .map((item) => InsightItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting current insights for user $userId: $e');
      return [];
    }
  }

  Future<List<InsightItem>> getInsightsWithFallback(String userId) async {
    final insights = await getCurrentInsights(userId);

    if (insights.isNotEmpty) {
      return insights;
    }

    // Return default insights when none exist
    return [
      InsightItem(
        title: '염증 지수',
        value: '보통',
        advice: '건강한 식단을 유지하고 충분한 휴식을 취하세요.',
        icon: 'local_fire_department_outlined',
        priority: 3,
      ),
      InsightItem(
        title: '스트레스',
        value: '보통',
        advice: '명상이나 가벼운 운동으로 스트레스를 관리해보세요.',
        icon: 'sentiment_very_dissatisfied_outlined',
        priority: 3,
      ),
      InsightItem(
        title: '다이어트 효율',
        value: '보통',
        advice: '식단에 단백질을 늘리고 규칙적인 운동을 시작해보세요.',
        icon: 'directions_run_outlined',
        priority: 3,
      ),
      InsightItem(
        title: '해독 능력',
        value: '좋음',
        advice: '몸의 해독 기능이 원활해요. 건강한 식단을 유지하세요.',
        icon: 'shield_outlined',
        priority: 3,
      ),
      InsightItem(
        title: '수면의 질',
        value: '보통',
        advice: '일정한 시간에 잠자리에 들어보세요.',
        icon: 'nightlight_round_outlined',
        priority: 3,
      ),
      InsightItem(
        title: '집중력 & 기분',
        value: '양호',
        advice: '집중력과 기분이 좋은 상태입니다. 꾸준히 유지하세요.',
        icon: 'psychology_outlined',
        priority: 3,
      ),
    ];
  }

  // ------------------------------------------------------------
  ///                       Health Metrics
  // ------------------------------------------------------------
}

final userServiceProvider = Provider<UserService>((ref) {
  final service = UserService();
  service.initialize();
  return service;
});
