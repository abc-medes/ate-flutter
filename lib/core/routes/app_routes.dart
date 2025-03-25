import 'package:ate_project/features/debug/debug_view.dart';
import 'package:ate_project/features/home/views/home_view.dart';
import 'package:ate_project/features/onboarding/views/intro_view.dart';
import 'package:go_router/go_router.dart';

final appRoutes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomeView(),
  ),
  GoRoute(
    path: '/debug',
    builder: (context, state) => const DebugView(),
  ),
  GoRoute(
    path: '/intro',
    builder: (context, state) => const IntroView(),
  ),
];
