import 'dart:async';
import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';

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
        emailRedirectTo: "bodido://auth/signup",
        data: {
          'name': name,
        });
    return authResponse;
  }

  Future<AuthResponse> signInWithEmail(
      {required String email, required String password}) async {
    final authResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return authResponse;
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email,
        redirectTo: "bodido://${RouteNames.resetPassword}");
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
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
