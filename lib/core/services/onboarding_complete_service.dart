import 'package:bodido/common_libs.dart';

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final client = Supabase.instance.client;
  final currentUser = client.auth.currentUser;

  // If user is not authenticated, onboarding is not complete
  if (currentUser == null) {
    return false;
  }

  try {
    // First, check if body simulator snapshot exists (main indicator)
    final snapshotResponse = await client
        .from('user_body_state_snapshots')
        .select('id')
        .eq('user_id', currentUser.id)
        .limit(1)
        .maybeSingle();

    if (snapshotResponse != null) {
      return true; // Body simulator data exists
    }

    // Fallback: check health_metrics for body_simulator_data
    final healthMetricsResponse = await client
        .from('health_metrics')
        .select('health_metrics')
        .eq('user_id', currentUser.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (healthMetricsResponse != null &&
        healthMetricsResponse['health_metrics'] != null) {
      final healthMetrics =
          healthMetricsResponse['health_metrics'] as Map<String, dynamic>;
      final bodySimulatorData = healthMetrics['body_simulator_data'];

      // Check if body_simulator_data exists and is not empty
      if (bodySimulatorData != null) {
        // Check if it has any meaningful data (not just empty state)
        final bodyState = bodySimulatorData as Map<String, dynamic>;
        // If bodyState has any non-null values, onboarding is complete
        final hasData = bodyState.values.any((v) => v != null);
        return hasData;
      }
    }

    return false; // No body simulator data found
  } catch (e) {
    debugPrint('Error checking onboarding status: $e');
    return false; // On error, assume onboarding not complete
  }
});
