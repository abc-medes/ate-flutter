import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'auth_routes.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    redirect: (context, state) {
      if (authState.isLoading || authState.errorMessage != null) {
        return '/auth/login';
      }

      if (!authState.isAuthenticated) {
        return state.matchedLocation.startsWith('/auth') ? null : '/auth/login';
      }

      if (!authState.isOnboardingCompleted) {
        return state.matchedLocation.startsWith('/auth/onboarding')
            ? null
            : '/auth/onboarding';
      }

      return null;
    },
    routes: [...authRoutes, ...appRoutes],
  );
});
