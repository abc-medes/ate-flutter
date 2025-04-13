import 'package:ate_project/features/auth/views/screens/login_view.dart';
import 'package:ate_project/features/auth/views/screens/email_checking_screen.dart';
// import 'package:ate_project/features/auth/views/onboarding_view.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(
    path: '/auth/login',
    builder: (context, state) => const LoginView(),
  ),
  GoRoute(
    path: '/auth/checking-email',
    builder: (context, state) {
      final email = state.extra as String;
      return EmailCheckingScreen(email: email);
    },
  ),
  GoRoute(
    path: '/auth/signup',
    builder: (context, state) {
      // If we have an email from checking, use it for the signup form
      final email = state.extra is String ? state.extra as String : null;
      // TODO: Create and return SignupView(email: email);
      // For now, we'll just redirect back to login as a placeholder
      return const LoginView();
    },
  ),
  // GoRoute(
  //   path: '/auth/onboarding',
  //   builder: (context, state) => const OnboardingView(),
  // ),
];
