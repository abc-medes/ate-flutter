import 'package:bodiapp/core/routes/route_names.dart';
import 'package:bodiapp/core/services/user_service.dart';
import 'package:bodiapp/core/services/keyboard_dismiss_on_navigation_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'auth_routes.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authServiceProvider);
  final userService = ref.watch(userServiceProvider);

  return GoRouter(
    observers: [KeyboardDismissOnNavigateObserver()],
    redirect: (context, state) {
      if (!authState.isAuthenticated) {
        return state.matchedLocation.startsWith('/auth')
            ? null
            : RouteNames.login;
      }

      if (authState.isAuthenticated && !userService.isBasicHealthDataComplete) {
        return RouteNames.settings;
      }

      return RouteNames.settings;
    },
    routes: [...authRoutes, ...appRoutes],
  );
});
