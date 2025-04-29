import 'package:ate_project/core/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'auth_routes.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    redirect: (context, state) {
      if (authState.isLoadingOrError) {
        return RouteNames.login;
      }

      if (!authState.isAuthenticated) {
        return state.matchedLocation.startsWith('/auth')
            ? null
            : RouteNames.login;
      }

      // if (userState.user != null && !userState.isOnboardingCompleted) {
      //   return state.matchedLocation.startsWith(RouteNames.onboarding)
      //       ? null
      //       : RouteNames.onboarding;
      // }

      return null;
    },
    routes: [...authRoutes, ...appRoutes],
  );
});
