import 'package:regene/core/routes/router_wrapper.dart';
import 'package:regene/data/models/chat_model.dart';
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
    (state) {
      if (state.extra is ChatMessage) {
        return ChatView(cm: state.extra as ChatMessage);
      }
      return HomeView();
    },
  ),
];
