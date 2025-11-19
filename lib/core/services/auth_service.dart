import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/services/app_lifecycle.dart';
import 'package:bodido/core/services/user_service.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/health_model.dart';
import 'package:bodido/data/models/profiles/user_model.dart' as um;
import 'package:bodido/data/repositories/user_repository.dart';
import 'package:url_launcher/url_launcher.dart'
    show closeInAppWebView, LaunchMode;
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
        redirectTo: "bodido.app://${RouteNames.changePassword}");
  }

  Future<void> resendSignupVerification(String email) async {
    const redirectTo = 'bodido.app://auth/signup';
    await _client.auth.resend(
      email: email,
      type: OtpType.signup,
      emailRedirectTo: redirectTo,
    );
  }

  Future<void> resendResetPasswordEmail(String email) async {
    const redirectTo = 'bodido.app://${RouteNames.changePassword}';
    await _client.auth.resend(
      email: email,
      type: OtpType.recovery,
      emailRedirectTo: redirectTo,
    );
  }

  Future<void> oauthLogin(OAuthProvider provider) async {
    const redirectTo = 'bodido.app://auth/signup';
    PlatformException? lastError;
    await _client.auth.signInWithOAuth(
      provider,
      redirectTo: redirectTo,
      authScreenLaunchMode: LaunchMode.inAppWebView,
    );
    throw lastError ?? PlatformException(code: 'launch_failed');
  }

  Future<AuthResponse> signInWithApple() async {
    final rawNonce = _client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
          'Could not find ID Token from generated credential.');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await userRepository.clearLocalHealthData();
    await userRepository.clearLocalOnboardingData();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _client.auth.currentUser?.email;
    if (email == null) {
      throw AuthException('Not signed in');
    }

    await _client.auth
        .signInWithPassword(email: email, password: currentPassword);
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ------------------------------------------------------------
  ///                       Profile

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

  Future<void> devWipeUserData(String uid) async {
    final c = _client;
    try {
      await c.from('chat_history').delete().eq('user_id', uid);
    } catch (_) {}
    try {
      await c.from('user_body_state_snapshots').delete().eq('user_id', uid);
    } catch (_) {}
    try {
      await c.from('personal_insights').delete().eq('user_id', uid);
    } catch (_) {}
    try {
      await c.from('health_metrics').delete().eq('user_id', uid);
    } catch (_) {}
    try {
      await c.from('profiles').delete().eq('id', uid);
    } catch (_) {}
  }

  Future<void> deleteAccount() async {
    final uid = currentUser?.id;
    if (uid == null) {
      await signOut();
      return;
    }
    await devWipeUserData(uid);
    await signOut();
  }
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

final lifecycleProvider = Provider<LifecycleLogic?>((ref) {
  final authed = ref.watch(isAuthedProvider);
  if (!authed) return null;

  final userService = ref.watch(userServiceProvider);
  final logic = LifecycleLogic(userService, ref as WidgetRef);

  ref.onDispose(() {
    logic.dispose();
  });
  return logic;
});
