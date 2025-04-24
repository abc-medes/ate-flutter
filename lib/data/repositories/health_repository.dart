import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ate_project/data/models/health_model.dart';

class HealthRepository {
  static const String _healthDataKey = 'health_data';

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
      UserInputField.preExistingConditions,
      UserInputField.medications,
      UserInputField.allergies,
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
      if (!isSaved) {
        missingFields.add(field);
      }
    }

    print(missingFields);

    return missingFields;
  }

  List<DailyUserData> getDailyUserDataFields() {
    return DailyUserData.values;
  }
}

// Create a provider for HealthRepository
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});
