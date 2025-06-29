import 'package:flutter/material.dart';

class KeyboardDismissOnNavigateObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _dismissKeyboard(route.navigator?.context);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _dismissKeyboard(route.navigator?.context);
    super.didPop(route, previousRoute);
  }

  void _dismissKeyboard(BuildContext? context) {
    if (context != null) {
      FocusScope.of(context).unfocus();
    }
  }
}
