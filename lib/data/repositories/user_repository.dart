// lib/data/repositories/user_repository.dart
import 'dart:convert';

import 'package:bodido/data/models/health_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodido/core/utils/logger.dart';

class UserRepository {
  Future<void> saveLocalHealthData(
      String userId, HealthMetrics healthData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'health_metrics';
      await prefs.setString(key, jsonEncode(healthData.toJson()));
    } catch (e) {
      AppLogger.error('Error saving health data to local storage: $e');
    }
  }

  Future<void> clearLocalHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('health_metrics');
    } catch (e) {
      AppLogger.error('Error clearing health data from local storage: $e');
    }
  }

  Future<void> clearLocalOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_complete');
    } catch (e) {
      AppLogger.error('Error clearing onboarding data from local storage: $e');
    }
  }
}

final userRepository = UserRepository();
