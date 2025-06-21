import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/features/auth/views/screens/email_login_input_view.dart';
import 'package:ate_project/features/auth/views/screens/login_view.dart';
import 'package:ate_project/features/auth/views/screens/signup_view.dart';
import 'package:ate_project/features/onboarding/views/screens/onboarding_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  AppRoute(
    RouteNames.login,
    (_) => LoginView(),
  ),
  AppRoute(
    RouteNames.signup,
    (state) =>
        SignupView(email: state.extra is String ? state.extra as String : ''),
    // path: '/auth/signup',
    // builder: (context, state) {
    //   final email = state.extra is String ? state.extra as String : '';
    //   return SignupView(email: email);
    // },
  ),
  AppRoute(
    RouteNames.emailLoginInput,
    (_) => EmailLoginInputView(),
  ),
  AppRoute(
    RouteNames.onboarding,
    (_) => const OnboardingView(),
  ),
];

/// Custom GoRoute sub-class to make the router declaration easier to read
class AppRoute extends GoRoute {
  AppRoute(String path, Widget Function(GoRouterState s) builder,
      {List<GoRoute> routes = const [], this.useFade = false})
      : super(
          path: path,
          routes: routes,
          pageBuilder: (context, state) {
            final pageContent = Scaffold(
              body: builder(state),
              resizeToAvoidBottomInset: false,
            );
            if (useFade || $styles.disableAnimations) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: pageContent,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            }
            return CupertinoPage(child: pageContent);
          },
        );
  final bool useFade;
}
