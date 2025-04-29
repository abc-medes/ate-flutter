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
      if (!authState.isAuthenticated) {
        return state.matchedLocation.startsWith('/auth')
            ? null
            : RouteNames.login;
      }

      return null;
    },
    routes: [...authRoutes, ...appRoutes],
  );
});
