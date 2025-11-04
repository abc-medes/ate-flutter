import 'package:bodido/common_libs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLifecycleRepository {
  static const _kLastOpenIso = 'app.last_open_iso';
  static const _kLastQuestionsRefreshIso = 'tracking.last_refresh_iso';
  final _rand = Random();

  Future<void> setLastOpen(DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastOpenIso, dt.toUtc().toIso8601String());
  }

  Future<DateTime?> getLastOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kLastOpenIso);
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> markQuestionsRefreshed([DateTime? dt]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kLastQuestionsRefreshIso,
      (dt ?? DateTime.now().toUtc()).toIso8601String(),
    );
  }

  Future<DateTime?> getLastQuestionsRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kLastQuestionsRefreshIso);
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<bool> shouldRefreshQuestions({
    Duration minInterval = const Duration(hours: 6),
    Duration maxJitter = const Duration(minutes: 30),
  }) async {
    final last = await getLastQuestionsRefresh();
    if (last == null) return true;
    final jitter = Duration(minutes: _rand.nextInt(maxJitter.inMinutes + 1));
    final now = DateTime.now().toUtc();
    return now.difference(last.toUtc()) >= (minInterval + jitter);
  }
}

final appLifecycleRepositoryProvider =
    Provider<AppLifecycleRepository>((_) => AppLifecycleRepository());
