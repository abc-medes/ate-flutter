import 'dart:io';
import 'package:ate_project/features/auth/view_models/login_view_model.dart';
import 'package:ate_project/features/auth/views/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends ConsumerWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider.notifier);
    final viewState = ref.watch(loginViewModelProvider);
    final authState = ref.watch(authProvider);

    // Check if loading from either auth state or local view state
    final isLoading = authState.isLoading || viewState.isLoading;

    // Get error message from either auth state or local view state
    final error = authState.errorMessage ?? viewState.error;

    // Check platform
    final bool isAndroid = Platform.isAndroid;
    final bool isIOS = Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
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
                const Text(
                  'Hi!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: viewState.emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      border: InputBorder.none,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => viewModel.onEmailChanged(),
                  ),
                ),

                if (!viewState.isEmailValid)
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

                if (viewState.showPassword) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: viewState.passwordController,
                      obscureText: !viewState.isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewState.isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: viewModel.togglePasswordVisibility,
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
                        : () async {
                            if (viewState.showPassword) {
                              if (await viewModel.handlePasswordLogin()) {
                                // Auth success, router will handle the navigation
                              }
                            } else {
                              bool emailExists =
                                  await viewModel.checkEmailExists(context);
                              if (!emailExists &&
                                  viewModel.validateEmail() &&
                                  viewState.emailController.text.isNotEmpty) {
                                if (context.mounted) {
                                  context.push(RouteNames.signup,
                                      extra: viewState.emailController.text);
                                }
                              }
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
                            viewState.showPassword ? 'Login' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // Forgot password link (only shown when password is visible)
                if (viewState.showPassword) ...[
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

                // Social login buttons
                // if (isAndroid || !isIOS)
                SocialAuthButton(
                  ref: ref,
                  text: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: AppColors.textPrimary,
                  onPressed: () => _handleSocialLogin(
                      context, ref, viewModel.handleGoogleSignIn),
                ),

                if (isAndroid && isIOS) const SizedBox(height: 12),

                if (isIOS || !isAndroid)
                  SocialAuthButton(
                    ref: ref,
                    text: 'Continue with Apple',
                    icon: Icons.apple,
                    iconColor: AppColors.textPrimary,
                    onPressed: () => _handleSocialLogin(
                        context, ref, viewModel.handleAppleSignIn),
                  ),

                // Facebook login button removed
                // TODO: Implement Facebook login

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
                          onPressed: () {
                            viewModel.clearError();
                          },
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

  void _handleSocialLogin(BuildContext context, WidgetRef ref,
      Future<void> Function() signInMethod) async {
    final supabase = Supabase.instance.client;

    await signInMethod();

    // Check if user profile exists after successful auth
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response == null && context.mounted) {
          // Profile doesn't exist, redirect to signup
          await supabase.auth.signOut();
          context.push(RouteNames.signup);
        }
      } catch (e) {
        // Error checking profile, assume it doesn't exist
        await supabase.auth.signOut();
        if (context.mounted) {
          context.push(RouteNames.signup);
        }
      }
    }
  }
}
