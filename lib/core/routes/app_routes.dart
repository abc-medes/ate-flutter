import 'package:regene/core/routes/router_wrapper.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/features/chat/views/screens/chat_history_view.dart';
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
    RouteNames.chatHistory,
    (_) => const ChatHistoryView(),
  ),
  AppRoute(
    RouteNames.chat,
    (state) {
      String? message;
      int? chatOffset;

      if (state.extra is Map<String, dynamic>) {
        final extra = state.extra as Map<String, dynamic>;
        message = extra['message'] as String?;
        chatOffset = extra['chatOffset'] as int?;
      }

      return ChatView(
        initialMessage: message,
        initialChatOffset: chatOffset,
      );
    },
  ),
];
