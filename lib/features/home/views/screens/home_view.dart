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
  final TextEditingController _messageController = TextEditingController();
  bool _hasShownAuthPrompt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndShowPrompt();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Check authentication status and show prompt if needed
  Future<void> _checkAuthAndShowPrompt() async {
    if (_hasShownAuthPrompt || !mounted) return;

    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      setState(() {
        _hasShownAuthPrompt = true;
      });

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
            if (!mounted) return;
            context.push(RouteNames.login);
          },
          onGoogleLogin: () {
            if (!mounted) return;
            ref.read(authProvider.notifier).signInWithGoogle();
          },
          onAppleLogin: Platform.isIOS
              ? () {
                  if (!mounted) return;
                  ref.read(authProvider.notifier).signInWithApple();
                }
              : null,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteNames.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
