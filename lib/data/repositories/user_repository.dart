// lib/data/repositories/user_repository.dart
import 'dart:convert';

import 'package:ate_project/data/models/health_model.dart';
import 'package:ate_project/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SB;

class UserRepository {
  final SB.SupabaseClient _client = SB.Supabase.instance.client;

  Future<void> createProfile(String userId, String email, String name) async {
    try {
      // First check if profile already exists
      final existingProfile = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existingProfile != null) {
        // Profile already exists, update it instead of inserting
        final updatedUser = User.newUser(
          id: userId,
          email: email,
          name: name,
        );

        await _client
            .from('profiles')
            .update(updatedUser.toJson())
            .eq('id', userId);

        print('Updated existing profile for user: $userId');
      } else {
        // No existing profile, create a new one
        final newUser = User.newUser(
          id: userId,
          email: email,
          name: name,
        );

        await _client.from('profiles').insert(newUser.toJson());
        print('Created new profile for user: $userId');
      }
    } catch (profileError) {
      print('Error in createProfile: $profileError');
      await _client.auth.signOut();
      throw Exception('Failed to create user profile: $profileError');
    }
  }

  Future<void> createEmptyUserHealthMetrics(String userId) async {
    try {
      final emptyHealthMetrics = HealthMetrics(
        userInputData: UserInputData(),
        autoDetectedData: AutoDetectedData(),
        environmentalData: EnvironmentalData(),
      );

      // Create the database record
      final now = DateTime.now();
      final healthData = {
        'user_id': userId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'health_metrics': emptyHealthMetrics.toJson(),
      };

      // Insert into database
      await _client.from('user_health_metrics').insert(healthData);

      // Also save to local storage
      await _saveLocalHealthData(userId, emptyHealthMetrics);
    } catch (healthDataError) {
      throw Exception('Failed to create user health data: $healthDataError');
    }
  }

  Future<void> _saveLocalHealthData(
      String userId, HealthMetrics healthData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_health_data_$userId';
      await prefs.setString(key, jsonEncode(healthData.toJson()));
    } catch (e) {
      print('Error saving health data to local storage: $e');
    }
  }
}
