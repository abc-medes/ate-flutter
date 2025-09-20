import 'package:bodido/core/routes/router_wrapper.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:bodido/features/chat/views/screens/chat_history_view.dart';
import 'package:bodido/features/chat/views/screens/chat_view.dart';
import 'package:bodido/features/home/views/screens/home_view.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/features/settings/views/screens/settings_view.dart';

final appRoutes = [
  AppRoute(
    RouteNames.home,
    (_) => const HomeView(),
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
      final extra = state.extra as Map<String, dynamic>?;
      final initialMessage = extra?['initialMessage'] as ChatMessageDTO?;
      final sessionIds = extra?['sessionIds'] as List<String>?;
      final selectedDate = extra?['selectedDate'] as DateTime?;

      return ChatView(
        initialMessage: initialMessage,
        sessionIds: sessionIds,
        selectedDate: selectedDate,
      );
    },
  ),
];
