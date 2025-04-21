import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ate_project/data/models/health_model.dart';

class HealthRepository {
  static const String _healthDataKey = 'health_data';

  // Get health data from SharedPreferences
  Future<HealthMetrics?> getHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? healthDataJson = prefs.getString(_healthDataKey);

      if (healthDataJson == null) {
        return null;
      }

      final Map<String, dynamic> healthData = jsonDecode(healthDataJson);
      return HealthMetrics.fromJson(healthData);
    } catch (e) {
      print('Error retrieving health data: $e');
      return null;
    }
  }

  // Save health data to SharedPreferences
  Future<bool> saveHealthData(HealthMetrics healthMetrics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String healthDataJson = jsonEncode(healthMetrics.toJson());

      return await prefs.setString(_healthDataKey, healthDataJson);
    } catch (e) {
      print('Error saving health data: $e');
      return false;
    }
  }

  // Update specific parts of health data
  Future<bool> updateUserInputData(UserInputData userData) async {
    try {
      final healthMetrics = await getHealthData();

      if (healthMetrics == null) {
        // Create new health metrics if none exists
        final newHealthMetrics = HealthMetrics(
          userInputData: userData,
          autoDetectedData: AutoDetectedData(),
          environmentalData: EnvironmentalData(),
        );
        return await saveHealthData(newHealthMetrics);
      }

      // Update existing health metrics with new user data
      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: userData,
      );

      return await saveHealthData(updatedHealthMetrics);
    } catch (e) {
      print('Error updating user input data: $e');
      return false;
    }
  }

  // Add a food intake entry
  Future<bool> addFoodIntake(FoodIntake foodIntake) async {
    try {
      final healthMetrics = await getHealthData();

      if (healthMetrics == null) {
        // Create new health metrics with just this food intake
        final nutritionData = NutritionData(
          recentMeals: [foodIntake],
        );

        final userInputData = UserInputData(
          nutritionData: nutritionData,
        );

        final newHealthMetrics = HealthMetrics(
          userInputData: userInputData,
          autoDetectedData: AutoDetectedData(),
          environmentalData: EnvironmentalData(),
        );

        return await saveHealthData(newHealthMetrics);
      }

      // Get existing nutrition data or create new
      final existingNutritionData = healthMetrics.userInputData.nutritionData;
      final List<FoodIntake> updatedMeals = [];

      // Add existing meals if any (limited to most recent 10)
      if (existingNutritionData?.recentMeals != null) {
        updatedMeals.addAll(existingNutritionData!.recentMeals!);
      }

      // Add new meal at the beginning
      updatedMeals.insert(0, foodIntake);

      // Keep only the 10 most recent meals to prevent excessive data growth
      if (updatedMeals.length > 10) {
        updatedMeals.removeRange(10, updatedMeals.length);
      }

      // Create updated nutrition data
      final updatedNutritionData = existingNutritionData != null
          ? existingNutritionData.copyWith(recentMeals: updatedMeals)
          : NutritionData(recentMeals: updatedMeals);

      // Create updated user input data
      final updatedUserInputData = healthMetrics.userInputData.copyWith(
        nutritionData: updatedNutritionData,
      );

      // Update health metrics
      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      return await saveHealthData(updatedHealthMetrics);
    } catch (e) {
      print('Error adding food intake: $e');
      return false;
    }
  }

  // Update activity data
  Future<bool> updateActivityData(PhysicalActivityData activityData) async {
    try {
      final healthMetrics = await getHealthData();

      if (healthMetrics == null) {
        // Create new health metrics if none exists
        final newHealthMetrics = HealthMetrics(
          userInputData: UserInputData(),
          autoDetectedData: AutoDetectedData(
            activityData: activityData,
          ),
          environmentalData: EnvironmentalData(),
        );
        return await saveHealthData(newHealthMetrics);
      }

      // Update existing health metrics with new activity data
      final updatedAutoDetectedData = healthMetrics.autoDetectedData.copyWith(
        activityData: activityData,
      );

      final updatedHealthMetrics = healthMetrics.copyWith(
        autoDetectedData: updatedAutoDetectedData,
      );

      return await saveHealthData(updatedHealthMetrics);
    } catch (e) {
      print('Error updating activity data: $e');
      return false;
    }
  }

  // Update environmental data
  Future<bool> updateEnvironmentalData(
      EnvironmentalData environmentalData) async {
    try {
      final healthMetrics = await getHealthData();

      if (healthMetrics == null) {
        // Create new health metrics if none exists
        final newHealthMetrics = HealthMetrics(
          userInputData: UserInputData(),
          autoDetectedData: AutoDetectedData(),
          environmentalData: environmentalData,
        );
        return await saveHealthData(newHealthMetrics);
      }

      // Update existing health metrics with new environmental data
      final updatedHealthMetrics = healthMetrics.copyWith(
        environmentalData: environmentalData,
      );

      return await saveHealthData(updatedHealthMetrics);
    } catch (e) {
      print('Error updating environmental data: $e');
      return false;
    }
  }

  // Clear all health data (for testing or user request)
  Future<bool> clearHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_healthDataKey);
    } catch (e) {
      print('Error clearing health data: $e');
      return false;
    }
  }

  // Update specific user profile field
  Future<bool> updateProfileField<T>(
      {required String fieldName, required T value}) async {
    try {
      final healthMetrics = await getHealthData();

      if (healthMetrics == null) {
        // Create new health metrics with just the specific field
        // Use UserInputData constructor with named parameters
        final userInputData = UserInputData(
          height: fieldName == 'height' && value is double ? value : null,
          weight: fieldName == 'weight' && value is double ? value : null,
          dateOfBirth:
              fieldName == 'dateOfBirth' && value is DateTime ? value : null,
          gender: fieldName == 'gender' && value is String ? value : null,
        );

        final newHealthMetrics = HealthMetrics(
          userInputData: userInputData,
          autoDetectedData: AutoDetectedData(),
          environmentalData: EnvironmentalData(),
        );

        return await saveHealthData(newHealthMetrics);
      }

      // Update existing user data with new field value
      UserInputData updatedUserInputData;

      switch (fieldName) {
        case 'height':
          if (value is double) {
            updatedUserInputData = healthMetrics.userInputData.copyWith(
              height: value,
            );
          } else {
            print('Invalid value type for height');
            return false;
          }
          break;
        case 'weight':
          if (value is double) {
            updatedUserInputData = healthMetrics.userInputData.copyWith(
              weight: value,
            );
          } else {
            print('Invalid value type for weight');
            return false;
          }
          break;
        case 'dateOfBirth':
          if (value is DateTime) {
            updatedUserInputData = healthMetrics.userInputData.copyWith(
              dateOfBirth: value,
            );
          } else {
            print('Invalid value type for dateOfBirth');
            return false;
          }
          break;
        case 'gender':
          if (value is String) {
            updatedUserInputData = healthMetrics.userInputData.copyWith(
              gender: value,
            );
          } else {
            print('Invalid value type for gender');
            return false;
          }
          break;
        default:
          print('Unknown field: $fieldName');
          return false;
      }

      // Update health metrics
      final updatedHealthMetrics = healthMetrics.copyWith(
        userInputData: updatedUserInputData,
      );

      return await saveHealthData(updatedHealthMetrics);
    } catch (e) {
      print('Error updating $fieldName: $e');
      return false;
    }
  }

  // Legacy methods kept for backward compatibility

  Future<bool> updateHeight(double height) async {
    return updateProfileField(fieldName: 'height', value: height);
  }

  Future<bool> updateWeight(double weight) async {
    return updateProfileField(fieldName: 'weight', value: weight);
  }

  Future<bool> updateDateOfBirth(DateTime dateOfBirth) async {
    return updateProfileField(fieldName: 'dateOfBirth', value: dateOfBirth);
  }

  Future<bool> updateGender(String gender) async {
    return updateProfileField(fieldName: 'gender', value: gender);
  }
}
