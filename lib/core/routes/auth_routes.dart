import 'package:ate_project/features/auth/views/screens/login_view.dart';
import 'package:ate_project/features/auth/views/screens/signup_view.dart';
import 'package:ate_project/features/onboarding/views/screens/onboarding_view.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(
    path: '/auth/login',
    builder: (context, state) => const LoginView(),
  ),
  GoRoute(
    path: '/auth/signup',
    builder: (context, state) {
      final email = state.extra is String ? state.extra as String : '';
      return SignupView(email: email);
    },
  ),
  GoRoute(
    path: '/auth/onboarding',
    builder: (context, state) => const OnboardingView(),
  ),
];
