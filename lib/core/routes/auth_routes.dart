import 'package:bodiapp/core/routes/route_names.dart';
import 'package:bodiapp/core/routes/router_wrapper.dart';
import 'package:bodiapp/features/auth/views/screens/email_login_input_view.dart';
import 'package:bodiapp/features/auth/views/screens/login_view.dart';
import 'package:bodiapp/features/auth/views/screens/reset_password_view.dart';
import 'package:bodiapp/features/auth/views/screens/signup_view.dart';
import 'package:bodiapp/features/onboarding/views/screens/onboarding_view.dart';

final authRoutes = [
  AppRoute(
    RouteNames.login,
    (_) => LoginView(),
  ),
  AppRoute(
    RouteNames.signup,
    (state) =>
        SignupView(email: state.extra is String ? state.extra as String : ''),
  ),
  AppRoute(
    RouteNames.emailLoginInput,
    (_) => EmailLoginInputView(),
  ),
  AppRoute(
    RouteNames.onboarding,
    (_) => const OnboardingView(),
  ),
  AppRoute(
    RouteNames.resetPassword,
    (_) => ResetPasswordView(),
  ),
];
