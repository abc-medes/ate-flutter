import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ate_project/core/services/user_service.dart';

// Base service providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return UserService(authService);
});

// Auth state enum
enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

// Auth state model (now without user data)
class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final bool isLoading;
  final String? userId;

  AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isLoading = false,
    this.userId,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isLoading,
    String? userId,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && userId != null;
  bool get isInitializing => status == AuthStatus.initial;
  bool get hasError => status == AuthStatus.error || errorMessage != null;

  // Explicitly check if loading or has error for router
  bool get isLoadingOrError => isLoading || errorMessage != null;
}

// Auth notifier (now just manages auth state, not user data)
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription<bool>? _authSubscription;

  AuthNotifier(this._authService) : super(AuthState()) {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _authSubscription = _authService.authStateChanges.listen(
      (isAuthenticated) {
        if (isAuthenticated) {
          state = AuthState(
            status: AuthStatus.authenticated,
            userId: _authService.currentUser?.id,
            isLoading: false,
          );
        } else {
          state = AuthState(
            status: AuthStatus.unauthenticated,
            isLoading: false,
          );
        }
      },
      onError: (error) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, status: AuthStatus.authenticating);

    try {
      await _authService.signIn(email, password);
      // Auth state will be updated by the stream listener
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signOut();
      // Auth state will be updated by the stream listener
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, status: AuthStatus.authenticating);

    try {
      await _authService.signInWithGoogle();
      // Auth state will be updated by the stream listener
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, status: AuthStatus.authenticating);

    try {
      await _authService.signInWithApple();
      // Auth state will be updated by the stream listener
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Helper auth providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});

// User ID provider that depends on auth state
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Current Supabase user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Stream of authentication state changes
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);

  // Stream of user IDs
  Stream<String?> get userIdStream =>
      _client.auth.onAuthStateChange.map((state) => state.session?.user.id);

  // Sign up with email and password
  Future<void> signUp(String email, String password, String name) async {
    try {
      print('Starting signup process for email: $email');

      // Create auth user
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      print('Auth user created: ${authResponse.user?.id}');

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      // Create initial profile data
      final profileData = {
        'id': authResponse.user!.id,
        'email': email,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
        'preferences': {
          'dark_mode': false,
          'notification_settings': {
            'push_enabled': true,
            'email_enabled': true,
          }
        },
        'onboarding_status': {
          'personal_info_completed': false,
          'health_profile_completed': false,
          'goals_completed': false,
        },
        'health_profile': {}
      };

      print(
          'Attempting to insert profile data for user: ${authResponse.user!.id}');

      try {
        // Check if profile already exists before inserting
        final existingProfile = await _client
            .from('profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .maybeSingle();

        if (existingProfile == null) {
          // Only insert if profile doesn't exist
          try {
            await _client.from('profiles').insert(profileData);
            print('Profile data inserted successfully');
          } catch (insertError) {
            // If it's a duplicate key error, try to update instead
            if (insertError
                .toString()
                .contains('duplicate key value violates unique constraint')) {
              print('Handling duplicate key error by updating profile');
              await _client
                  .from('profiles')
                  .update(profileData)
                  .eq('id', authResponse.user!.id);
              print('Profile updated successfully after duplicate key error');
            } else {
              // For other errors, rethrow
              throw insertError;
            }
          }
        } else {
          // Profile exists, update it
          await _client
              .from('profiles')
              .update(profileData)
              .eq('id', authResponse.user!.id);
          print('Existing profile updated successfully');
        }
      } catch (profileError) {
        print('ERROR CREATING PROFILE: $profileError');
        // If profile creation fails, we should try to clean up the auth user
        try {
          await _client.auth.signOut();
          print('Signed out user after profile creation failed');
        } catch (deleteError) {
          print('Failed to sign out user: $deleteError');
        }
        throw Exception('Failed to create user profile: $profileError');
      }
    } catch (e) {
      print('SIGNUP ERROR: $e');
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to sign in');
      }
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Check if email is available - without trying fake passwords
  Future<bool> isEmailAvailable(String email) async {
    try {
      // We'll create a Supabase function for this later
      // For now, let's return true to skip this check
      return true;
    } catch (e) {
      throw Exception('Failed to check email: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      throw Exception('Failed to sign in with Apple: ${e.toString()}');
    }
  }

  // Fetch user profile from the database
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', userId).single();

      return response ?? {};
    } catch (e) {
      // If no profile exists, return empty map
      return {};
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _client.from('profiles').update(data).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Send email verification code
  Future<void> sendEmailVerificationCode(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
    } catch (e) {
      throw Exception('Failed to send verification code: ${e.toString()}');
    }
  }

  // Verify email with OTP code
  Future<AuthResponse> verifyEmailWithOTP(String email, String otp) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to verify email: ${e.toString()}');
    }
  }
}
