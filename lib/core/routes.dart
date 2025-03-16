import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/presentation/views/home/home_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/views/auth/login_view.dart';
// import '../presentation/views/auth/register_view.dart';
// import '../presentation/views/app/dashboard_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    redirect: (context, state) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isAuthenticated = authService.isAuthenticated;

      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login'; // Redirect unauthenticated users to login
      }

      if (isAuthenticated && isAuthRoute) {
        return '/'; // Redirect authenticated users to home
      }

      return null; // No redirection needed
    },
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginView(),
      ),
      // GoRoute(
      //   path: '/auth/register',
      //   builder: (context, state) => const RegisterView(),
      // ),

      // Application Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeView(),
      ),
      // GoRoute(
      //   path: '/dashboard',
      //   builder: (context, state) => const DashboardView(),
      // ),
    ],
  );
}
