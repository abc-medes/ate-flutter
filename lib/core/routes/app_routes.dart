import 'package:ate_project/features/body_simulator/views/screens/body_simulator_view.dart';
import 'package:ate_project/features/debug/debug_view.dart';
import 'package:ate_project/features/home/views/screens/home_view.dart';
import 'package:ate_project/features/onboarding/views/intro_view.dart';
import 'package:ate_project/features/settings/views/screens/settings_view.dart';
import 'package:ate_project/core/routes/route_names.dart';

final appRoutes = [
  (
    path: '/',
    builder: (context, state) => const HomeView(),
    // pageBuilder: (context, state) => _buildBottomTransitionPage(
    //   context,
    //   state,
    //   const HomeView(),
    // ),
  ),
  (
    path: '/debug',
    builder: (context, state) => const DebugView(),
  ),
  (
    path: '/intro',
    builder: (context, state) => const IntroView(),
  ),
  (
    path: RouteNames.settings,
    builder: (context, state) => const SettingsView(),
  ),
  (
    path: '/body-simulator',
    builder: (context, state) => const BodySimulatorView(),
  ),
];
