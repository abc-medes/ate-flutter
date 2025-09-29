import 'package:bodido/common_libs.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
});
