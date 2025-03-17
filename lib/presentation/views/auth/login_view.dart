import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: authState.isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (authState.errorMessage != null)
                    Text(authState.errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () async {
                      await authNotifier.login(
                          userId: "123", email: "test@example.com");
                      if (authState.isAuthenticated) {
                        context.go('/home'); // Navigate after login
                      }
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
      ),
    );
  }
}
