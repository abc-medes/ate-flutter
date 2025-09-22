import 'dart:async';
import 'dart:ui';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/common/platform_info.dart';
import 'package:bodido/core/services/api_service.dart';
import 'package:bodido/features/_utils/page_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

class AppLogic {
  Size _appSize = Size.zero;

  bool isBootstrapComplete = false;

  List<Axis> supportedOrientations = [Axis.vertical];

  List<Axis>? _supportedOrientationsOverride;
  set supportedOrientationsOverride(List<Axis>? value) {
    if (_supportedOrientationsOverride != value) {
      _supportedOrientationsOverride = value;
      _updateSystemOrientation();
    }
  }

  /// Initialize the app and all main actors.
  /// Loads settings, sets up services etc.
  Future<void> bootstrap() async {
    debugPrint('bootstrap start...');

    // Set preferred refresh rate to the max possible (the OS may ignore this)
    if (!kIsWeb && PlatformInfo.isAndroid) {
      await FlutterDisplayMode.setHighRefreshRate();
    }

    // Settings
    await settingsLogic.load();

    // Localizations
    await localeLogic.load();

    // inside bootstrap():
    unawaited(ApiService.checkServerHealth());

    // Wait at least 1 frame to give GoRouter time to catch the initial deeplink
    await Future.delayed(1.milliseconds);

    isBootstrapComplete = true;

    bool showIntro = settingsLogic.hasCompletedOnboarding.value == false;
    if (showIntro) {}
  }

  Future<T?> showFullscreenDialogRoute<T>(BuildContext context, Widget child,
      {bool transparent = false}) async {
    return await Navigator.of(context).push<T>(
      PageRoutes.dialog<T>(child, duration: $styles.times.pageTransition),
    );
  }

  /// Called from the UI layer once a MediaQuery has been obtained
  void handleAppSizeChanged(Size appSize) {
    /// Disable landscape layout on smaller form factors
    bool isSmall = display.size.shortestSide / display.devicePixelRatio < 600;
    supportedOrientations =
        isSmall ? [Axis.vertical] : [Axis.vertical, Axis.horizontal];
    _updateSystemOrientation();
    _appSize = appSize;
  }

  Display get display => PlatformDispatcher.instance.displays.first;

  bool shouldUseNavRail() =>
      _appSize.width > _appSize.height && _appSize.height > 250;

  void _updateSystemOrientation() {
    final axisList = _supportedOrientationsOverride ?? supportedOrientations;
    //debugPrint('updateDeviceOrientation, supportedAxis: $axisList');
    final orientations = <DeviceOrientation>[];
    if (axisList.contains(Axis.vertical)) {
      orientations.addAll([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    if (axisList.contains(Axis.horizontal)) {
      orientations.addAll([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    SystemChrome.setPreferredOrientations(orientations);
  }
}

class AppImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    this.imageCache.maximumSizeBytes = 250 << 20; // 250mb
    return super.createImageCache();
  }
}
