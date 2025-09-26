import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugView extends ConsumerWidget {
  const DebugView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Debug View")),
      body: Column(
        children: [
          CupertinoButton(
            child: const Text("Go to Home"),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                context.go(RouteNames.home);
              }
            },
          ),
          CupertinoButton(
            child: const Text("Go to Home"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('health_metrics');
            },
          ),
        ],
      ),
    );
  }
}
