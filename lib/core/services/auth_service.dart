import 'dart:async';
import 'package:ate_project/common_libs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final authResponse =
        await _client.auth.signUp(email: email, password: password, data: {
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
    await _client.auth.resetPasswordForEmail(email);
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    );
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
