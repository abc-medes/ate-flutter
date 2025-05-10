import 'dart:convert';
import 'package:ate_project/features/onboarding/views/widgets/gender_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ate_project/data/models/health_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SB;

class HealthRepository {
  final SB.SupabaseClient _client = SB.Supabase.instance.client;
  static const String _healthDataKey = 'health_metrics';

  Future<bool> isUserInputFieldSaved(UserInputField field) async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_healthDataKey)) {
      return false;
    }

    try {
      final jsonString = prefs.getString(_healthDataKey);
      if (jsonString == null) return false;

      final healthData = jsonDecode(jsonString);

      if (healthData == null || !healthData.containsKey('user_input_data')) {
        return false;
      }

      final userInputData = healthData['user_input_data'];

      String fieldName = _getFieldJsonKey(field);
      return userInputData.containsKey(fieldName);
    } catch (e) {
      return false;
    }
  }

  String _getFieldJsonKey(UserInputField field) {
    switch (field) {
      case UserInputField.height:
        return 'height';
      case UserInputField.weight:
        return 'weight';
      case UserInputField.dateOfBirth:
        return 'date_of_birth';
      case UserInputField.gender:
        return 'gender';
      case UserInputField.preExistingConditions:
        return 'pre_existing_conditions';
      case UserInputField.medications:
        return 'medications';
      case UserInputField.allergies:
        return 'allergies';
      case UserInputField.nutritionData:
        return 'nutrition_data';
      case UserInputField.moodData:
        return 'mood_data';
      case UserInputField.symptoms:
        return 'symptoms';
      case UserInputField.sleepQuality:
        return 'sleep_quality';
      case UserInputField.activityData:
        return 'activity_data';
      case UserInputField.memorizedData:
        return 'memorized_data';
    }
  }

  Future<bool> isBasicUserDataSaved(BasicUserData field) async {
    return isUserInputFieldSaved(field.toUserInputField());
  }

  Future<List<UserInputField>> getMissingUserInputFields() async {
    final missingFields = <UserInputField>[];

    final importantFields = [
      UserInputField.height,
      UserInputField.weight,
      UserInputField.dateOfBirth,
      UserInputField.gender,
      // UserInputField.preExistingConditions,
      // UserInputField.medications,
      // UserInputField.allergies,
    ];

    for (final field in importantFields) {
      final isSaved = await isUserInputFieldSaved(field);
      if (!isSaved) {
        missingFields.add(field);
      }
    }

    print(missingFields);

    return missingFields;
  }

  Future<List<BasicUserData>> getMissingBasicUserData() async {
    final missingFields = <BasicUserData>[];

    for (final field in BasicUserData.values) {
      final isSaved = await isBasicUserDataSaved(field);

      // TODO: Remove this once we have a way to save allergies and medications
      if (!isSaved) {
        missingFields.add(field);
      }
    }

    return missingFields;
  }

  List<DailyUserData> getDailyUserDataFields() {
    return DailyUserData.values;
  }

  Future<HealthMetrics> _getExistingHealthMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsString = prefs.getString('health_metrics');

      if (metricsString != null) {
        return HealthMetrics.fromJson(jsonDecode(metricsString));
      }
    } catch (e) {
      print('Error retrieving health metrics: $e');
    }

    // Return empty health metrics if none exist
    return HealthMetrics(
      userInputData: UserInputData(),
      autoDetectedData: AutoDetectedData(),
      environmentalData: EnvironmentalData(),
    );
  }

  Future<void> saveHeightAndWeight(int height, int weight) async {
    try {
      final healthMetrics = await _getExistingHealthMetrics();

      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        height: height.toDouble(),
        weight: weight.toDouble(),
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await _saveHealthMetricsToStorage(updatedHealthMetrics);

      await _saveHealthMetricsToDatabase(updatedHealthMetrics);
    } catch (e) {
      print('Error saving height and weight: $e');
    }
  }

  Future<void> saveMemorizedData(String data) async {
    try {
      final healthMetrics = await _getExistingHealthMetrics();

      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        memorizedData: data,
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await _saveHealthMetricsToStorage(updatedHealthMetrics);

      await _saveHealthMetricsToDatabase(updatedHealthMetrics);
    } catch (e) {
      print('Error saving memorized data: $e');
    }
  }

  Future<void> saveBirthDate(DateTime birthDate) async {
    try {
      final healthMetrics = await _getExistingHealthMetrics();

      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        dateOfBirth: birthDate,
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await _saveHealthMetricsToStorage(updatedHealthMetrics);

      await _saveHealthMetricsToDatabase(updatedHealthMetrics);
    } catch (e) {
      print('Error saving birth date: $e');
    }
  }

  Future<void> saveGender(Gender gender) async {
    try {
      // Get existing health metrics if available
      final healthMetrics = await _getExistingHealthMetrics();

      // Update with new gender
      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        gender: gender.toString().split('.').last, // Convert enum to string
      );

      // Create updated health metrics
      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await _saveHealthMetricsToStorage(updatedHealthMetrics);
      await _saveHealthMetricsToDatabase(updatedHealthMetrics);
    } catch (e) {
      print('Error saving gender: $e');
      rethrow;
    }
  }

  Future<void> _saveHealthMetricsToStorage(HealthMetrics metrics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('health_metrics', jsonEncode(metrics.toJson()));
    } catch (e) {
      print('Error saving health metrics: $e');
    }
  }

  Future<void> _saveHealthMetricsToDatabase(HealthMetrics metrics) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final healthMetricsJson = metrics.toJson();

      await _client
          .from('health_metrics')
          .update({'health_metrics': healthMetricsJson}).eq('user_id', userId);

      print('Health metrics updated successfully');
    } catch (e) {
      print('Error saving health metrics: $e');
    }
  }
}

final healthRepository = HealthRepository();
