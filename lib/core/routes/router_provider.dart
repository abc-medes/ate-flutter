import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/services/onboarding_complete_service.dart';
import 'package:bodido/core/utils/keyboard_dismiss_on_navigation_observer.dart';

import '../services/auth_service.dart';
import 'app_routes.dart';
import 'auth_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthed = ref.watch(isAuthedProvider);

  return GoRouter(
    observers: [KeyboardDismissOnNavigateObserver()],
    redirect: (context, state) {
      final uri = state.uri;
      final path = uri.path;
      final host = uri.host;

      if (!isAuthed) {
        final isAuthTarget = path.startsWith('/auth') || host == 'auth';
        if (isAuthTarget) return null;
        return RouteNames.login;
      }

      if (path == RouteNames.changePassword) {
        return RouteNames.changePassword;
      }

      final onboardingAsync = ref.watch(onboardingCompleteProvider);
      if (onboardingAsync.isLoading) return null;

      final onboardingDone = onboardingAsync.value ?? false;

      if (!onboardingDone) {
        return RouteNames.onboarding;
      }

      return null;
    },
    routes: [...authRoutes, ...appRoutes],
  );
});
