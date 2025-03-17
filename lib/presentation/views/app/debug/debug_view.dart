import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugView extends ConsumerWidget {
  const DebugView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debug View")),
      body: const Center(
        child: Text("Use this view as debug"),
      ),
    );
  }
}
