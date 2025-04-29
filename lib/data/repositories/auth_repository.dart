import 'package:supabase_flutter/supabase_flutter.dart' as SB;

class AuthRepository {
  final SB.SupabaseClient _client = SB.Supabase.instance.client;

  Future<SB.AuthResponse> signUp(String email, String password) async {
    try {
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      return authResponse;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
