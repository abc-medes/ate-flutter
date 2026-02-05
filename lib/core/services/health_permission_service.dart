import 'package:health/health.dart';

/// Handles all health data permissions exclusively (iOS HealthKit / Android Health Connect).
/// Use this service for requesting and checking permissions; do not mix with
/// [permission_handler] for health types — the [health] package owns health authorization.
class HealthPermissionService {
  HealthPermissionService() : _health = Health();

  final Health _health;

  /// Data types we request access for. Add/remove here to change what the app can read/write.
  static const List<HealthDataType> typesToRead = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.WORKOUT,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_GLUCOSE,
  ];

  /// Types we may write (e.g. weight from app). Default is read-only for most.
  static const List<HealthDataType> typesToWrite = [
    HealthDataType.WEIGHT,
    HealthDataType.WORKOUT,
  ];

  /// All types we need permission for (read or write).
  static List<HealthDataType> get allRequestedTypes {
    final set = <HealthDataType>{...typesToRead, ...typesToWrite};
    return set.toList();
  }

  /// Permissions for [allRequestedTypes]: READ for read-only list, READ_WRITE for write list.
  static List<HealthDataAccess> get permissionsForRequestedTypes {
    return allRequestedTypes.map((type) {
      return typesToWrite.contains(type)
          ? HealthDataAccess.READ_WRITE
          : HealthDataAccess.READ;
    }).toList();
  }

  /// Check if we have permission for the requested health types.
  /// On iOS, HealthKit may not disclose READ grant (returns null); on Android returns true/false.
  Future<bool> hasPermissions() async {
    try {
      final result = await _health.hasPermissions(
        typesToRead,
        permissions: _readOnlyPermissions(typesToRead),
      );
      return result == true;
    } catch (e) {
      return false;
    }
  }

  List<HealthDataAccess> _readOnlyPermissions(List<HealthDataType> types) {
    return List.filled(types.length, HealthDataAccess.READ);
  }

  /// Request authorization for all configured health data types.
  /// Shows the system permission sheet (HealthKit on iOS, Health Connect on Android).
  /// Returns true if the permission UI was shown without error (on iOS, READ grant is not disclosed).
  Future<bool> requestAuthorization() async {
    try {
      final types = allRequestedTypes;
      final permissions = permissionsForRequestedTypes;
      return await _health.requestAuthorization(types,
          permissions: permissions);
    } catch (e) {
      return false;
    }
  }

  /// Request only read access for the default read types (no write).
  Future<bool> requestReadOnlyAuthorization() async {
    try {
      return await _health.requestAuthorization(
        typesToRead,
        permissions: _readOnlyPermissions(typesToRead),
      );
    } catch (e) {
      return false;
    }
  }

  /// Revoke permissions (if supported on platform). Use sparingly.
  Future<bool> revokePermissions() async {
    try {
      await _health.revokePermissions();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Health instance for use when reading/writing data (e.g. getHealthDataFromTypes).
  Health get health => _health;
}
