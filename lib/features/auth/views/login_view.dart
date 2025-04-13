import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/core/theme/app_theme.dart';

class LoginView extends ConsumerStatefulWidget {
  static String get routeName => RouteNames.login;

  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),

            // Logo/Branding Area (Placeholder for asset)
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                // TODO: Replace with actual logo
                child: const Center(
                  child: Text(
                    'LOGO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),

            // Subtitle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Text(
                  '건강한 삶을 위한 첫 걸음',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ),

            // Login Form
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Field
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: '이메일',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '비밀번호',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: Text(
                          '비밀번호를 잊으셨나요?',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement login
                      },
                      child: const Text('로그인'),
                    ),

                    const SizedBox(height: 40),

                    // Social Login Separator
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.textTertiary),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '또는',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.textTertiary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social Login Buttons (Placeholders for assets)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialLoginButton(
                          onTap: () {
                            // TODO: Implement Google login
                          },
                          child: const Icon(
                            Icons.g_mobiledata,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 24),
                        _SocialLoginButton(
                          onTap: () {
                            // TODO: Implement Apple login
                          },
                          child: const Icon(
                            Icons.apple,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialLoginButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: child),
      ),
    );
  }
}
