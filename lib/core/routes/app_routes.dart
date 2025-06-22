import 'package:ate_project/core/routes/router_wrapper.dart';
import 'package:ate_project/features/home/views/screens/home_view.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/features/settings/views/screens/settings_view.dart';

final appRoutes = [
  AppRoute(
    RouteNames.home,
    (_) => const HomeView(),
  ),
  AppRoute(
    RouteNames.settings,
    (_) => const SettingsView(),
  ),
];
