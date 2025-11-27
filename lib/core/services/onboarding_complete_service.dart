import 'package:bodido/common_libs.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final client = Supabase.instance.client;
  final currentUser = client.auth.currentUser;

  if (currentUser == null) {
    return false;
  }

  final prefs = await SharedPreferences.getInstance();
  final savedOnboardingComplete = prefs.getBool('onboarding_complete');

  if (savedOnboardingComplete != null) {
    return savedOnboardingComplete;
  }

  return false;
});
