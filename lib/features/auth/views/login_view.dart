import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/services/auth_service.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome Back',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await authNotifier.login(
                    userId: "123", email: "test@example.com");
                if (authState.isAuthenticated) {
                  context.go('/intro'); // Navigate after login
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
