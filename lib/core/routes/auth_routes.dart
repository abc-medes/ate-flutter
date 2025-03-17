import 'package:ate_project/presentation/views/auth/login_view.dart';
import 'package:ate_project/presentation/views/auth/onboarding_view.dart';
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
