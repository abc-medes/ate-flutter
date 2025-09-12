import 'package:bodai/core/routes/route_names.dart';
import 'package:bodai/core/services/user_service.dart';
import 'package:bodai/core/utils/keyboard_dismiss_on_navigation_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'auth_routes.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthed = ref.watch(isAuthedProvider);
  final userService = ref.watch(userServiceProvider);

  return GoRouter(
    observers: [KeyboardDismissOnNavigateObserver()],
    redirect: (context, state) {
      if (!isAuthed) {
        return state.matchedLocation.startsWith('/auth')
            ? null
            : RouteNames.login;
      }
      if (!userService.isBasicHealthDataComplete) {
        return RouteNames.onboarding;
      }
      return null;
    },
    routes: [...authRoutes, ...appRoutes],
  );
});
