import 'package:regene/core/routes/route_names.dart';
import 'package:regene/core/routes/router_wrapper.dart';
import 'package:regene/features/auth/views/screens/email_login_input_view.dart';
import 'package:regene/features/auth/views/screens/login_view.dart';
import 'package:regene/features/auth/views/screens/reset_password_view.dart';
import 'package:regene/features/auth/views/screens/signup_view.dart';
import 'package:regene/features/onboarding/views/screens/onboarding_view.dart';

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
