// lib/data/repositories/user_repository.dart
import 'dart:convert';

import 'package:bodai/data/models/health_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  Future<void> saveLocalHealthData(
      String userId, HealthMetrics healthData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'health_metrics';
      await prefs.setString(key, jsonEncode(healthData.toJson()));
    } catch (e) {
      print('Error saving health data to local storage: $e');
    }
  }
}

final userRepository = UserRepository();
