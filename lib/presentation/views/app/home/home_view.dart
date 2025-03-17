import 'package:ate_project/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Home!"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: Text("Go to Dashboard"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authNotifier.logout();
                context.go('/auth/login'); // Redirect to login on logout
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
