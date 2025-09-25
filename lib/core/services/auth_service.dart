import 'dart:async';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/health_model.dart';
import 'package:bodido/data/models/profiles/user_model.dart' as um;
import 'package:url_launcher/url_launcher.dart'
    show closeInAppWebView, LaunchMode;

enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);
  Stream<String?> get userIdStream =>
      _client.auth.onAuthStateChange.map((state) => state.session?.user.id);

  Future<AuthResponse> signUpWithEmail(
      {required String email,
      required String password,
      required String name}) async {
    final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: "bodido.app://auth/signup",
        data: {
          'name': name,
        });
    return authResponse;
  }

  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email,
        redirectTo: "bodido.app://${RouteNames.resetPassword}");
  }

  Future<void> resendSignupVerification(String email) async {
    const redirectTo = 'bodido.app://auth/signup';
    await _client.auth.resend(
      email: email,
      type: OtpType.signup,
      emailRedirectTo: redirectTo,
    );
  }

  Future<void> signInWithGoogle() async {
    final done = _client.auth.onAuthStateChange
        .firstWhere((e) =>
            e.event == AuthChangeEvent.signedIn ||
            e.event == AuthChangeEvent.userUpdated)
        .then((_) => closeInAppWebView());

    const redirectTo = 'bodido.app://auth/login-callback';

    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
      authScreenLaunchMode: LaunchMode.platformDefault,
    );

    await done;
  }

  Future<void> signInWithApple() async {
    final done = _client.auth.onAuthStateChange
        .firstWhere((e) =>
            e.event == AuthChangeEvent.signedIn ||
            e.event == AuthChangeEvent.userUpdated)
        .then((_) => closeInAppWebView());
    const redirectTo = 'bodido.app://auth/login-callback';

    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: redirectTo,
      authScreenLaunchMode: LaunchMode.platformDefault,
    );

    await done;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ------------------------------------------------------------
  ///                       Profile
  // ------------------------------------------------------------
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
  // ------------------------------------------------------------
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

extension on AuthService {
  Stream<Session?> get sessionChanges =>
      _client.auth.onAuthStateChange.map((e) => e.session);
}

final sessionProvider = StreamProvider<Session?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.sessionChanges;
});

final isAuthedProvider = Provider<bool>((ref) {
  return ref.watch(sessionProvider).value != null;
});
