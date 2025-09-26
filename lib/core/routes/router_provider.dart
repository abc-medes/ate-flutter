import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
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
        return isAuthTarget ? null : RouteNames.login;
      }

      return null;
    },
    routes: [...authRoutes, ...appRoutes],
  );
});
