import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/core/services/health_permission_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugView extends ConsumerStatefulWidget {
  const DebugView({super.key});

  @override
  ConsumerState<DebugView> createState() => _DebugViewState();
}

class _DebugViewState extends ConsumerState<DebugView> {
  bool _isLoadingHealthData = false;
  List<HealthDataPoint>? _healthDataPoints;
  String? _healthDataError;

  Future<void> _fetchHealthData() async {
    if (_isLoadingHealthData) return;
    setState(() {
      _isLoadingHealthData = true;
      _healthDataError = null;
      _healthDataPoints = null;
    });

    try {
      await healthPermissionService.requestAuthorization();

      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 7));
      final types = HealthPermissionService.typesToRead;

      final points =
          await healthPermissionService.health.getHealthDataFromTypes(
        types: types,
        startTime: start,
        endTime: now,
      );

      if (mounted) {
        setState(() {
          _healthDataPoints = points;
          _isLoadingHealthData = false;
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _healthDataError = '$e';
          _isLoadingHealthData = false;
        });
      }
      debugPrint('Health data fetch error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
        title: const Text("Debug View"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const Text('Device health data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isLoadingHealthData ? null : _fetchHealthData,
            icon: _isLoadingHealthData
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.health_and_safety_outlined, size: 20),
            label: Text(_isLoadingHealthData
                ? 'Fetching…'
                : 'Fetch health data (last 7 days)'),
          ),
          if (_healthDataError != null) ...[
            const SizedBox(height: 8),
            Text(
              _healthDataError!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ],
          if (_healthDataPoints != null) ...[
            const SizedBox(height: 8),
            Text('${_healthDataPoints!.length} points',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            ..._healthDataPoints!
                .take(200)
                .map((p) => _HealthDataPointTile(point: p)),
            if (_healthDataPoints!.length > 200)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('… and ${_healthDataPoints!.length - 200} more',
                    style: const TextStyle(fontSize: 12)),
              ),
          ],
          const Padding(padding: EdgeInsets.only(top: 24)),
          const Text('Account / storage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text("Logout"),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) context.go(RouteNames.home);
            },
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text("delete health metrics"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('health_metrics');
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('health_metrics removed')));
            },
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text("회원 탈퇴 (dev)"),
            onPressed: () async {
              try {
                if (context.mounted) context.go(RouteNames.home);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _HealthDataPointTile extends StatelessWidget {
  const _HealthDataPointTile({required this.point});

  final HealthDataPoint point;

  @override
  Widget build(BuildContext context) {
    final valueStr = point.value.toString();
    final dateStr = _formatDate(point.dateFrom);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        title: Text(point.typeString,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
            '$valueStr ${point.unitString} · $dateStr\n${point.sourceName}'),
        dense: true,
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
