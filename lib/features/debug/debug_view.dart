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
            child: const Text("Logout"),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                context.go(RouteNames.home);
              }
            },
          ),
          CupertinoButton(
            child: const Text("delete health metrics"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('health_metrics');
            },
          ),
          CupertinoButton(
            child: const Text("회원 탈퇴 (dev)"),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              try {
                await authService.devAccountDeleteSoft();
                if (context.mounted) context.go(RouteNames.home);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
