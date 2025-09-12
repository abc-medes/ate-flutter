import 'package:bodai/common_libs.dart';
import 'package:bodai/core/services/session_service.dart';
import 'package:bodai/core/services/user_service.dart';
import 'package:uuid/uuid.dart';

/// Keeps the user’s profile in sync with app-lifecycle events (open / close).
/// If no user is logged-in `currentUser` is `null`, so the calls are skipped.
class LifecycleLogic with WidgetsBindingObserver {
  final UserService _userService;
  final WidgetRef _ref;

  LifecycleLogic(this._userService, this._ref) {
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
      case AppLifecycleState.resumed:
        _ref.read(sessionIdProvider.notifier).state = const Uuid().v4();
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
