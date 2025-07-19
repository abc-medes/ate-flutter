import 'package:regene/core/routes/router_wrapper.dart';
import 'package:regene/features/chat/views/screens/chat_view.dart';
import 'package:regene/features/home/views/screens/home_view.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:regene/features/settings/views/screens/settings_view.dart';

final appRoutes = [
  AppRoute(
    RouteNames.home,
    (_) => HomeView(),
  ),
  AppRoute(
    RouteNames.settings,
    (_) => const SettingsView(),
  ),
  AppRoute(
    RouteNames.chat,
    (state) => ChatView(
      prompt: state.extra as String? ?? '',
    ),
  ),
];
