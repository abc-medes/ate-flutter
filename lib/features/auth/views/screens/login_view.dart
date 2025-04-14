import 'dart:io';
import 'package:ate_project/features/auth/views/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ate_project/core/widgets/loading_screen.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _showPassword = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return _emailController.text.isEmpty ||
        emailRegex.hasMatch(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading || _isLoading;
    final error = authState.errorMessage;

    // Check platform
    final bool isAndroid = Platform.isAndroid;
    final bool isIOS = Platform.isIOS;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hi! Text
                const Text(
                  'Hi!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      border: InputBorder.none,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      setState(() {
                        _isEmailValid = _validateEmail();
                        // Reset password visibility if email changes
                        if (_showPassword) {
                          _showPassword = false;
                        }
                      });
                    },
                  ),
                ),

                // Show error below the TextField if validation fails
                if (!_isEmailValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Text(
                      'Please enter a valid email',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Password field (only shown after email check)
                if (_showPassword) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_validateEmail() &&
                                _emailController.text.isNotEmpty) {
                              if (_showPassword) {
                                _handlePasswordLogin(context);
                              } else {
                                _checkEmailExists(context);
                              }
                            } else {
                              setState(() {
                                _isEmailValid = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.surface,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _showPassword ? 'Login' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // Forgot password link (only shown when password is visible)
                if (_showPassword) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement forgot password flow
                      },
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Or divider
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (isAndroid || !isIOS)
                  SocialAuthButton(
                      ref: ref,
                      text: 'Continue with Google',
                      icon: Icons.g_mobiledata,
                      iconColor: Colors.red,
                      onPressed: () => _handleGoogleSignIn(ref)),

                if (isAndroid && !isIOS) const SizedBox(height: 12),

                if (isIOS || !isAndroid)
                  SocialAuthButton(
                      ref: ref,
                      text: 'Continue with Apple',
                      icon: Icons.apple,
                      iconColor: AppColors.surface,
                      onPressed: () => _handleAppleSignIn(ref)),

                const SizedBox(height: 12),

                SocialAuthButton(
                    ref: ref,
                    text: 'Continue with Facebook',
                    icon: Icons.facebook,
                    iconColor: AppColors.secondary,
                    onPressed: () {
                      // TODO: Implement Facebook login
                    }),

                // Error message if any
                if (error != null)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              ref.read(authProvider.notifier).clearError(),
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkUserProfileExists(User? user) async {
    if (user == null) return;

    try {
      // Check if user profile exists in the profiles table
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        // Profile doesn't exist, redirect to signup
        await _supabase.auth.signOut();
        if (mounted) {
          context.push(RouteNames.signup);
        }
      }
    } catch (e) {
      // Error checking profile, assume it doesn't exist
      await _supabase.auth.signOut();
      if (mounted) {
        context.push(RouteNames.signup);
      }
    }
  }

  Future<void> _checkEmailExists(BuildContext context) async {
    if (!_validateEmail() || _emailController.text.isEmpty) {
      setState(() {
        _isEmailValid = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the authService method to check if email exists
      final authService = ref.read(authServiceProvider);
      final isEmailAvailable =
          await authService.isEmailAvailable(_emailController.text);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (isEmailAvailable) {
        // Email doesn't exist - go to signup
        context.push(RouteNames.signup, extra: _emailController.text);
      } else {
        // Email exists - show password field
        setState(() {
          _showPassword = true;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show error
      ref.read(authProvider.notifier).state =
          ref.read(authProvider.notifier).state.copyWith(
                errorMessage: "Error checking email: ${e.toString()}",
              );
    }
  }

  void _handlePasswordLogin(BuildContext context) async {
    if (_passwordController.text.isEmpty) {
      // Show password error
      ref.read(authProvider.notifier).state =
          ref.read(authProvider.notifier).state.copyWith(
                errorMessage: "Please enter your password",
              );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to sign in with password
      await _supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Auth success, router will handle the navigation
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show login error
      ref.read(authProvider.notifier).state =
          ref.read(authProvider.notifier).state.copyWith(
                errorMessage: "Login failed: ${e.toString()}",
              );
    }
  }

  void _handleGoogleSignIn(WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();

      // Check if user profile exists after successful auth
      _checkUserProfileExists(_supabase.auth.currentUser);
    } catch (e) {
      // Error will be handled by the AuthNotifier
    }
  }

  void _handleAppleSignIn(WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).signInWithApple();

      // Check if user profile exists after successful auth
      _checkUserProfileExists(_supabase.auth.currentUser);
    } catch (e) {
      // Error will be handled by the AuthNotifier
    }
  }
}
