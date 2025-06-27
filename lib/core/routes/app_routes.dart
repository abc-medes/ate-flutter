import 'package:bodiapp/core/routes/router_wrapper.dart';
import 'package:bodiapp/features/home/views/screens/home_view.dart';
import 'package:bodiapp/core/routes/route_names.dart';
import 'package:bodiapp/features/settings/views/screens/settings_view.dart';

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
