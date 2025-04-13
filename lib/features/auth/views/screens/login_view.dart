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
  bool _isEmailValid = true;
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
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
    final isLoading = authState.isLoading;
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
                      });
                    },
                  ),
                ),
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
                              _handleEmailLogin(context);
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
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
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
                const SizedBox(height: 40),

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

  void _handleEmailLogin(BuildContext context) async {
    if (!_validateEmail() || _emailController.text.isEmpty) {
      setState(() {
        _isEmailValid = false;
      });
      return;
    }

    // Navigate to a loading screen that directly handles the checking
    context.push(RouteNames.checkingEmail, extra: _emailController.text);
  }

  void _handleGoogleSignIn(WidgetRef ref) async {
    LoadingScreen.show(context, message: "Connecting to Google...");

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();

      // Always dismiss loading screen when operation completes
      LoadingScreen.dismiss(context);

      if (!mounted) return;

      // Check if user profile exists after successful auth
      _checkUserProfileExists(_supabase.auth.currentUser);
    } catch (e) {
      // Always dismiss loading screen when operation fails
      LoadingScreen.dismiss(context);
      // Error will be handled by the AuthNotifier
    }
  }

  void _handleAppleSignIn(WidgetRef ref) async {
    LoadingScreen.show(context, message: "Connecting to Apple...");

    try {
      await ref.read(authProvider.notifier).signInWithApple();

      // Always dismiss loading screen when operation completes
      LoadingScreen.dismiss(context);

      if (!mounted) return;

      // Check if user profile exists after successful auth
      _checkUserProfileExists(_supabase.auth.currentUser);
    } catch (e) {
      // Always dismiss loading screen when operation fails
      LoadingScreen.dismiss(context);
      // Error will be handled by the AuthNotifier
    }
  }
}
