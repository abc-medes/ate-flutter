import 'dart:convert';
import 'package:bodai/data/models/body_simulator_model.dart';
import 'package:bodai/features/onboarding/views/widgets/body_type_pidcker.dart';
import 'package:bodai/features/onboarding/views/widgets/gender_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodai/data/models/health_model.dart';

class HealthRepository {
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
      case UserInputField.bodyType:
        return 'body_type';
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

    final importantFields =
        BasicUserData.values.map((field) => field.toUserInputField()).toList();

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

    return missingFields;
  }

  List<DailyUserData> getDailyUserDataFields() {
    return DailyUserData.values;
  }

  Future<HealthMetrics> getExistingHealthMetrics() async {
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
      bodySimulatorData: BodySimulatorState.empty(),
    );
  }

  Future<void> saveHeightAndWeight(int height, int weight) async {
    try {
      final healthMetrics = await getExistingHealthMetrics();

      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        height: height.toDouble(),
        weight: weight.toDouble(),
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await saveHealthMetricsToStorage(updatedHealthMetrics);
    } catch (e) {
      print('Error saving height and weight: $e');
    }
  }

  Future<void> saveBodyType(BodyType bodyType) async {
    try {
      final healthMetrics = await getExistingHealthMetrics();
      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        bodyType: bodyType.displayName,
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await saveHealthMetricsToStorage(updatedHealthMetrics);
    } catch (e) {
      print('Error saving body type: $e');
    }
  }

  Future<void> saveMemorizedData(data) async {
    try {
      final healthMetrics = await getExistingHealthMetrics();

      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        memorizedData: data,
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await saveHealthMetricsToStorage(updatedHealthMetrics);
    } catch (e) {
      print('Error saving memorized data: $e');
    }
  }

  Future<void> saveBirthDate(DateTime birthDate) async {
    try {
      final healthMetrics = await getExistingHealthMetrics();

      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        dateOfBirth: birthDate,
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await saveHealthMetricsToStorage(updatedHealthMetrics);
    } catch (e) {
      print('Error saving birth date: $e');
    }
  }

  Future<void> saveGender(Gender gender) async {
    try {
      final healthMetrics = await getExistingHealthMetrics();

      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        gender: gender.toString().split('.').last, // Convert enum to string
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      await saveHealthMetricsToStorage(updatedHealthMetrics);
    } catch (e) {
      print('Error saving gender: $e');
      rethrow;
    }
  }

  Future<void> saveHealthMetricsToStorage(HealthMetrics metrics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('health_metrics', jsonEncode(metrics.toJson()));
    } catch (e) {
      print('Error saving health metrics: $e');
    }
  }
}

final healthRepository = HealthRepository();
