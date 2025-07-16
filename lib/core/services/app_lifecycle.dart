import 'package:regene/common_libs.dart';
import 'package:regene/core/services/user_service.dart';

/// Keeps the user’s profile in sync with app-lifecycle events (open / close).
/// If no user is logged-in `currentUser` is `null`, so the calls are skipped.
class LifecycleLogic with WidgetsBindingObserver {
  final UserService _userService;

  LifecycleLogic(this._userService) {
    // Register for lifecycle callbacks right away.
    WidgetsBinding.instance.addObserver(this);

    // Immediately mark the session as “opened”.
    _markAppOpened();
  }

  /// MUST be called to avoid leaks (e.g. in your root widget’s dispose).
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /* ─────────────────────────────────────────────── */

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed: // App foreground
        _markAppOpened();
        break;
      case AppLifecycleState.paused: // Sent to background
      case AppLifecycleState.detached: // Terminated
        _markAppClosed();
        break;
      default:
        break;
    }
  }

  /* ───────────────────────── helpers ───────────────────────── */

  void _markAppOpened() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _userService.setUserAppOpened(user.id);
    }
  }

  void _markAppClosed() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _userService.setUserAppClosed(user.id);
    }
  }
}
