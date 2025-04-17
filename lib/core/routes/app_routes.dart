import 'package:ate_project/features/debug/debug_view.dart';
import 'package:ate_project/features/home/views/screens/home_view.dart';
import 'package:ate_project/features/onboarding/views/intro_view.dart';
import 'package:ate_project/features/settings/views/screens/settings_view.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/routes/route_names.dart';

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
  GoRoute(
    path: RouteNames.settings,
    builder: (context, state) => const SettingsView(),
  ),
];
