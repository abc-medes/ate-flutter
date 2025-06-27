import 'package:bodiapp/common_libs.dart';
import 'package:flutter/cupertino.dart';

/// Custom GoRoute sub-class to make the router declaration easier to read
class AppRoute extends GoRoute {
  AppRoute(String path, Widget Function(GoRouterState s) builder,
      {List<GoRoute> routes = const [], this.useFade = false})
      : super(
          path: path,
          routes: routes,
          pageBuilder: (context, state) {
            final Widget pageContent = AppScaffold(
              child: builder(state),
            );
            // final pageContent = Scaffold(
            //   body: builder(state),
            //   resizeToAvoidBottomInset: false,
            // );
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
