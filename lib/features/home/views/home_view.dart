import 'package:ate_project/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/features/auth/views/login_view.dart';
import 'package:ate_project/core/routes/route_names.dart';

class HomeView extends ConsumerWidget {
  static String get routeName => RouteNames.home;

  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authNotifier.logout();
              context.go(LoginView.routeName);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Home!"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/debug'),
              child: Text("Go to Debug"),
            ),
          ],
        ),
      ),
    );
  }
}
