import 'package:ate_project/features/auth/views/login_view.dart';
import 'package:ate_project/features/auth/views/onboarding_view.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(
    path: '/auth/login',
    builder: (context, state) => const LoginView(),
  ),
  GoRoute(
    path: '/auth/onboarding',
    builder: (context, state) => const OnboardingView(),
  ),
];
