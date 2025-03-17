import 'package:ate_project/presentation/views/app/debug/debug_view.dart';
import 'package:ate_project/presentation/views/app/home/home_view.dart';
import 'package:go_router/go_router.dart';

final appRoutes = [
  GoRoute(
    path: '/home',
    builder: (context, state) => const HomeView(),
  ),
  GoRoute(
    path: '/debug',
    builder: (context, state) => const DebugView(),
  ),
];
