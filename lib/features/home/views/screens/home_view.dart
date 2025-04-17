import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/services/user_service.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/widgets/auth_prompt_modal.dart';
import 'dart:io' show Platform;

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  bool _hasShownAuthPrompt = false;

  @override
  void initState() {
    super.initState();
    // Schedule the auth check after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndShowPrompt();
    });
  }

  // Check authentication status and show prompt if needed
  Future<void> _checkAuthAndShowPrompt() async {
    if (_hasShownAuthPrompt) return;
    if (_hasShownAuthPrompt || !mounted) return;

    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      _hasShownAuthPrompt = true;

      final shouldLogin = await AuthPromptHelper.showLoginPrompt(
        context,
        title: 'Welcome to the App',
        message:
            'Sign in to access all features and personalize your experience.',
      );

      if (shouldLogin && mounted) {
        await AuthPromptHelper.showLoginActionSheet(
          context,
          onEmailLogin: () {
            context.push(RouteNames.login);
          },
          onGoogleLogin: () {
            _handleGoogleSignIn();
          },
          onAppleLogin: Platform.isIOS ? _handleAppleSignIn : null,
        );
      }
    }
  }

  void _handleGoogleSignIn() {
    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.signInWithGoogle();
  }

  void _handleAppleSignIn() {
    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.signInWithApple();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final authState = ref.watch(authProvider);
    final user = userState.user;
    final isAuthenticated = authState.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteNames.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: userState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAuthenticated
                          ? 'Welcome ${user?.name ?? 'User'}!'
                          : 'Welcome Guest!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAuthenticated
                          ? 'You are signed in. Enjoy all features!'
                          : 'Sign in to access all features.',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Home Screen',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'This is a placeholder for your app\'s main content.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isAuthenticated) ...[
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          final shouldLogin =
                              await AuthPromptHelper.showLoginPrompt(context);
                          if (shouldLogin && mounted) {
                            context.push(RouteNames.login);
                          }
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
