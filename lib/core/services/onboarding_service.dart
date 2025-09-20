import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/health_model.dart';

class OnboardingService {
  final _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<void> saveHealthMetricsToDatabase(HealthMetrics metrics) async {
    if (_uid == null) {
      throw Exception('User not logged in');
    }

    final healthMetricsJson = metrics.toJson();

    await _client
        .from('health_metrics')
        .update({'health_metrics': healthMetricsJson}).eq('user_id', _uid!);
  }
}

/// Provider
final onboardingServiceProvider = Provider((_) => OnboardingService());
