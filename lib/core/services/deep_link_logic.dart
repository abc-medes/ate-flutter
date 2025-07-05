import 'package:regene/core/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class DeepLinkLogic {
  StreamSubscription? _sub;

  void init(BuildContext context) {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        // Example: ateapp://reset-password?access_token=XYZ
        if (uri.host == RouteNames.resetPassword) {
          final token = uri.queryParameters['access_token'];
          // Use your router or Navigator to go to the reset password screen
          Navigator.pushNamed(context, RouteNames.resetPassword,
              arguments: token);
        }
      }
    }, onError: (err) {
      // Handle errors
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}
