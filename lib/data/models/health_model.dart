import 'package:flutter/material.dart';

/**
 * HEALTH DATA PRIORITY LEVELS
 * 
 * HIGH PRIORITY (Frequently changing, daily tracking):
 * - Food/nutrition intake (meals, water)
 * - Physical activity (steps, workouts)
 * - Sleep patterns
 * - Mood and symptoms
 * - Weather and environmental conditions
 * 
 * MEDIUM PRIORITY (Weekly tracking):
 * - Weight changes
 * - Screen time patterns
 * - Activity trends
 * 
 * LOW PRIORITY (Infrequent changes):
 * - Height, gender, date of birth
 * - Chronic health conditions
 * - Allergies
 * - Long-term medications
 */

enum HealthDataCategory { userInput, autoDetected, environmental }

enum UserInputField {
  height,
  weight,
  dateOfBirth,
  gender,
  preExistingConditions,
  medications,
  allergies,
  memorizedData,

  nutritionData,
  moodData,
  symptoms,
  sleepQuality,
  activityData
}

enum BasicUserData {
  height,
  weight,
  dateOfBirth,
  gender,
}

// Extension to convert between BasicUserData and UserInputField
extension BasicUserDataExtension on BasicUserData {
  UserInputField toUserInputField() {
    switch (this) {
      case BasicUserData.height:
        return UserInputField.height;
      case BasicUserData.weight:
        return UserInputField.weight;
      case BasicUserData.dateOfBirth:
        return UserInputField.dateOfBirth;
      case BasicUserData.gender:
        return UserInputField.gender;
    }
  }
}

// Conceptual grouping of UserInputField into daily tracking data
enum DailyUserData {
  nutritionData,
  moodData,
  symptoms,
  sleepQuality,
  activityData
}

// Extension to convert between DailyUserData and UserInputField
extension DailyUserDataExtension on DailyUserData {
  UserInputField toUserInputField() {
    switch (this) {
      case DailyUserData.nutritionData:
        return UserInputField.nutritionData;
      case DailyUserData.moodData:
        return UserInputField.moodData;
      case DailyUserData.symptoms:
        return UserInputField.symptoms;
      case DailyUserData.sleepQuality:
        return UserInputField.sleepQuality;
      case DailyUserData.activityData:
        return UserInputField.activityData;
    }
  }
}

// Extension to check if UserInputField is BasicUserData or DailyUserData
extension UserInputFieldExtension on UserInputField {
  bool get isBasicUserData {
    return this == UserInputField.height ||
        this == UserInputField.weight ||
        this == UserInputField.dateOfBirth ||
        this == UserInputField.gender ||
        this == UserInputField.preExistingConditions ||
        this == UserInputField.medications ||
        this == UserInputField.allergies ||
        this == UserInputField.memorizedData;
  }

  bool get isDailyUserData {
    return this == UserInputField.nutritionData ||
        this == UserInputField.moodData ||
        this == UserInputField.symptoms ||
        this == UserInputField.sleepQuality ||
        this == UserInputField.activityData ||
        this == UserInputField.memorizedData;
  }

  BasicUserData? toBasicUserData() {
    if (!isBasicUserData) return null;

    switch (this) {
      case UserInputField.height:
        return BasicUserData.height;
      case UserInputField.weight:
        return BasicUserData.weight;
      case UserInputField.dateOfBirth:
        return BasicUserData.dateOfBirth;
      case UserInputField.gender:
        return BasicUserData.gender;
      default:
        return null;
    }
  }

  DailyUserData? toDailyUserData() {
    if (!isDailyUserData) return null;

    switch (this) {
      case UserInputField.nutritionData:
        return DailyUserData.nutritionData;
      case UserInputField.moodData:
        return DailyUserData.moodData;
      case UserInputField.symptoms:
        return DailyUserData.symptoms;
      case UserInputField.sleepQuality:
        return DailyUserData.sleepQuality;
      case UserInputField.activityData:
        return DailyUserData.activityData;
      default:
        return null;
    }
  }
}

enum AutoDetectedField {
  activityData,
  screenTimeData,
  sleepDurationData,
  locationData,
  heartRateData
}

enum EnvironmentalField {
  weatherData,
  airQualityData,
  uvIndexData,
  pollenData,
  seasonalData
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive
}

enum ExerciseType {
  walking,
  running,
  cycling,
  swimming,
  weightLifting,
  yoga,
  pilates,
  hiit,
  teamSports,
  other
}

enum DietType {
  regular,
  vegetarian,
  vegan,
  pescatarian,
  paleo,
  keto,
  lowCarb,
  lowFat,
  mediterranean,
  other
}

enum MoodLevel { veryNegative, negative, neutral, positive, veryPositive }

enum Season { spring, summer, fall, winter }

class HealthMetrics {
  final UserInputData userInputData;

  final AutoDetectedData autoDetectedData;

  final EnvironmentalData environmentalData;

  HealthMetrics({
    required this.userInputData,
    required this.autoDetectedData,
    required this.environmentalData,
  });

  // Calculate BMI if height and weight are available
  double? get bmi {
    if (userInputData.height == null ||
        userInputData.weight == null ||
        userInputData.height == 0) {
      return null;
    }
    return userInputData.weight! /
        ((userInputData.height! / 100) * (userInputData.height! / 100));
  }

  // Get BMI category
  String? get bmiCategory {
    if (bmi == null) {
      return null;
    }
    if (bmi! < 18.5) {
      return 'Underweight';
    }
    if (bmi! < 25) {
      return 'Normal weight';
    }
    if (bmi! < 30) {
      return 'Overweight';
    }
    return 'Obese';
  }

  int? get age {
    if (userInputData.dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - userInputData.dateOfBirth!.year;
    if (today.month < userInputData.dateOfBirth!.month ||
        (today.month == userInputData.dateOfBirth!.month &&
            today.day < userInputData.dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  bool get isBasicProfileComplete =>
      userInputData.height != null &&
      userInputData.weight != null &&
      userInputData.dateOfBirth != null &&
      userInputData.gender != null;

  List<String> get homeSuggestions {
    final suggestions = <String>[];

    if (userInputData.nutritionData?.recentMeals == null ||
        userInputData.nutritionData!.recentMeals!.isEmpty) {
      suggestions.add('Log your meals for today');
    }

    if (autoDetectedData.activityData == null ||
        autoDetectedData.activityData!.steps < 1000) {
      suggestions.add('Track your daily activity');
    }

    if (autoDetectedData.sleepDurationData == null) {
      suggestions.add('Record your sleep duration');
    }

    if (userInputData.moodData == null) {
      suggestions.add('How are you feeling today?');
    }

    suggestions.add('Check today\'s air quality (미세먼지)');

    return suggestions;
  }

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      userInputData: UserInputData.fromJson(json['user_input_data'] ?? {}),
      autoDetectedData:
          AutoDetectedData.fromJson(json['auto_detected_data'] ?? {}),
      environmentalData:
          EnvironmentalData.fromJson(json['environmental_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_input_data': userInputData.toJson(),
      'auto_detected_data': autoDetectedData.toJson(),
      'environmental_data': environmentalData.toJson(),
    };
  }

  HealthMetrics copyWith({
    UserInputData? userInputData,
    AutoDetectedData? autoDetectedData,
    EnvironmentalData? environmentalData,
  }) {
    return HealthMetrics(
      userInputData: userInputData ?? this.userInputData,
      autoDetectedData: autoDetectedData ?? this.autoDetectedData,
      environmentalData: environmentalData ?? this.environmentalData,
    );
  }
}

// Data that requires user manual input
class UserInputData {
  // Map each enum field to its corresponding data
  final Map<UserInputField, dynamic> _data = {};

  // LOW PRIORITY - infrequent changes
  double? get height => _data[UserInputField.height] as double?; // in cm
  double? get weight => _data[UserInputField.weight]
      as double?; // in kg - MEDIUM PRIORITY as it may change weekly
  DateTime? get dateOfBirth => _data[UserInputField.dateOfBirth] as DateTime?;
  String? get gender => _data[UserInputField.gender] as String?;
  List<HealthCondition>? get preExistingConditions =>
      _data[UserInputField.preExistingConditions] as List<HealthCondition>?;
  List<Medication>? get medications =>
      _data[UserInputField.medications] as List<Medication>?;
  List<Allergy>? get allergies =>
      _data[UserInputField.allergies] as List<Allergy>?;
  String? get memorizedData => _data[UserInputField.memorizedData] as String?;
  // HIGH PRIORITY - daily tracking
  NutritionData? get nutritionData =>
      _data[UserInputField.nutritionData] as NutritionData?;
  MoodData? get moodData => _data[UserInputField.moodData] as MoodData?;
  SymptomData? get symptoms => _data[UserInputField.symptoms] as SymptomData?;
  SleepQualityData? get sleepQuality =>
      _data[UserInputField.sleepQuality] as SleepQualityData?;

  UserInputData({
    double? height,
    double? weight,
    DateTime? dateOfBirth,
    String? gender,
    List<HealthCondition>? preExistingConditions,
    List<Medication>? medications,
    List<Allergy>? allergies,
    NutritionData? nutritionData,
    MoodData? moodData,
    SymptomData? symptoms,
    SleepQualityData? sleepQuality,
    String? memorizedData,
  }) {
    if (height != null) {
      _data[UserInputField.height] = height;
    }
    if (weight != null) {
      _data[UserInputField.weight] = weight;
    }
    if (dateOfBirth != null) {
      _data[UserInputField.dateOfBirth] = dateOfBirth;
    }
    if (gender != null) {
      _data[UserInputField.gender] = gender;
    }
    if (preExistingConditions != null) {
      _data[UserInputField.preExistingConditions] = preExistingConditions;
    }
    if (medications != null) {
      _data[UserInputField.medications] = medications;
    }
    if (allergies != null) {
      _data[UserInputField.allergies] = allergies;
    }
    if (nutritionData != null) {
      _data[UserInputField.nutritionData] = nutritionData;
    }
    if (moodData != null) {
      _data[UserInputField.moodData] = moodData;
    }
    if (symptoms != null) {
      _data[UserInputField.symptoms] = symptoms;
    }
    if (sleepQuality != null) {
      _data[UserInputField.sleepQuality] = sleepQuality;
    }
    if (memorizedData != null) {
      _data[UserInputField.memorizedData] = memorizedData;
    }
  }

  factory UserInputData.fromJson(Map<String, dynamic> json) {
    return UserInputData(
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      preExistingConditions: json['pre_existing_conditions'] != null
          ? List<HealthCondition>.from(json['pre_existing_conditions']
              .map((x) => HealthCondition.fromJson(x)))
          : null,
      medications: json['medications'] != null
          ? List<Medication>.from(
              json['medications'].map((x) => Medication.fromJson(x)))
          : null,
      allergies: json['allergies'] != null
          ? List<Allergy>.from(
              json['allergies'].map((x) => Allergy.fromJson(x)))
          : null,
      nutritionData: json['nutrition_data'] != null
          ? NutritionData.fromJson(json['nutrition_data'])
          : null,
      moodData: json['mood_data'] != null
          ? MoodData.fromJson(json['mood_data'])
          : null,
      symptoms: json['symptoms'] != null
          ? SymptomData.fromJson(json['symptoms'])
          : null,
      sleepQuality: json['sleep_quality'] != null
          ? SleepQualityData.fromJson(json['sleep_quality'])
          : null,
      memorizedData: json['memorized_data'],
    );
  }

  Map<String, dynamic> toJson() {
    final jsonMap = <String, dynamic>{};

    // Convert based on enum fields
    if (_data.containsKey(UserInputField.height)) {
      jsonMap['height'] = height;
    }
    if (_data.containsKey(UserInputField.weight)) {
      jsonMap['weight'] = weight;
    }
    if (_data.containsKey(UserInputField.dateOfBirth)) {
      jsonMap['date_of_birth'] = dateOfBirth?.toIso8601String();
    }
    if (_data.containsKey(UserInputField.gender)) {
      jsonMap['gender'] = gender;
    }
    if (_data.containsKey(UserInputField.preExistingConditions)) {
      jsonMap['pre_existing_conditions'] =
          preExistingConditions?.map((x) => x.toJson()).toList();
    }
    if (_data.containsKey(UserInputField.medications)) {
      jsonMap['medications'] = medications?.map((x) => x.toJson()).toList();
    }
    if (_data.containsKey(UserInputField.allergies)) {
      jsonMap['allergies'] = allergies?.map((x) => x.toJson()).toList();
    }
    if (_data.containsKey(UserInputField.nutritionData)) {
      jsonMap['nutrition_data'] = nutritionData?.toJson();
    }
    if (_data.containsKey(UserInputField.moodData)) {
      jsonMap['mood_data'] = moodData?.toJson();
    }
    if (_data.containsKey(UserInputField.symptoms)) {
      jsonMap['symptoms'] = symptoms?.toJson();
    }
    if (_data.containsKey(UserInputField.sleepQuality)) {
      jsonMap['sleep_quality'] = sleepQuality?.toJson();
    }
    if (_data.containsKey(UserInputField.memorizedData)) {
      jsonMap['memorized_data'] = memorizedData;
    }

    return jsonMap;
  }

  // Set a field by enum
  void setField(UserInputField field, dynamic value) {
    _data[field] = value;
  }

  // Get a field by enum
  dynamic getField(UserInputField field) {
    return _data[field];
  }

  // Check if a field exists
  bool hasField(UserInputField field) {
    return _data.containsKey(field);
  }

  UserInputData copyWith({
    double? height,
    double? weight,
    DateTime? dateOfBirth,
    String? gender,
    List<HealthCondition>? preExistingConditions,
    List<Medication>? medications,
    List<Allergy>? allergies,
    NutritionData? nutritionData,
    MoodData? moodData,
    SymptomData? symptoms,
    SleepQualityData? sleepQuality,
    String? memorizedData,
  }) {
    final newData = UserInputData();

    // Copy existing data
    newData._data.addAll(_data);

    // Update with new values if provided
    if (height != null) {
      newData._data[UserInputField.height] = height;
    }
    if (weight != null) {
      newData._data[UserInputField.weight] = weight;
    }
    if (dateOfBirth != null) {
      newData._data[UserInputField.dateOfBirth] = dateOfBirth;
    }
    if (gender != null) {
      newData._data[UserInputField.gender] = gender;
    }
    if (preExistingConditions != null) {
      newData._data[UserInputField.preExistingConditions] =
          preExistingConditions;
    }
    if (medications != null) {
      newData._data[UserInputField.medications] = medications;
    }
    if (allergies != null) {
      newData._data[UserInputField.allergies] = allergies;
    }
    if (nutritionData != null) {
      newData._data[UserInputField.nutritionData] = nutritionData;
    }
    if (moodData != null) {
      newData._data[UserInputField.moodData] = moodData;
    }
    if (symptoms != null) {
      newData._data[UserInputField.symptoms] = symptoms;
    }
    if (sleepQuality != null) {
      newData._data[UserInputField.sleepQuality] = sleepQuality;
    }
    if (memorizedData != null) {
      newData._data[UserInputField.memorizedData] = memorizedData;
    }
    return newData;
  }
}

// Data that can be automatically collected via phone sensors, etc.
class AutoDetectedData {
  // Map each enum field to its corresponding data
  final Map<AutoDetectedField, dynamic> _data = {};

  PhysicalActivityData? get activityData =>
      _data[AutoDetectedField.activityData] as PhysicalActivityData?;
  ScreenTimeData? get screenTimeData =>
      _data[AutoDetectedField.screenTimeData] as ScreenTimeData?;
  SleepDurationData? get sleepDurationData =>
      _data[AutoDetectedField.sleepDurationData] as SleepDurationData?;
  LocationData? get locationData =>
      _data[AutoDetectedField.locationData] as LocationData?;
  HeartRateData? get heartRateData =>
      _data[AutoDetectedField.heartRateData] as HeartRateData?;

  AutoDetectedData({
    PhysicalActivityData? activityData,
    ScreenTimeData? screenTimeData,
    SleepDurationData? sleepDurationData,
    LocationData? locationData,
    HeartRateData? heartRateData,
  }) {
    if (activityData != null) {
      _data[AutoDetectedField.activityData] = activityData;
    }
    if (screenTimeData != null) {
      _data[AutoDetectedField.screenTimeData] = screenTimeData;
    }
    if (sleepDurationData != null) {
      _data[AutoDetectedField.sleepDurationData] = sleepDurationData;
    }
    if (locationData != null) {
      _data[AutoDetectedField.locationData] = locationData;
    }
    if (heartRateData != null) {
      _data[AutoDetectedField.heartRateData] = heartRateData;
    }
  }

  factory AutoDetectedData.fromJson(Map<String, dynamic> json) {
    return AutoDetectedData(
      activityData: json['activity_data'] != null
          ? PhysicalActivityData.fromJson(json['activity_data'])
          : null,
      screenTimeData: json['screen_time_data'] != null
          ? ScreenTimeData.fromJson(json['screen_time_data'])
          : null,
      sleepDurationData: json['sleep_duration_data'] != null
          ? SleepDurationData.fromJson(json['sleep_duration_data'])
          : null,
      locationData: json['location_data'] != null
          ? LocationData.fromJson(json['location_data'])
          : null,
      heartRateData: json['heart_rate_data'] != null
          ? HeartRateData.fromJson(json['heart_rate_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final jsonMap = <String, dynamic>{};

    if (_data.containsKey(AutoDetectedField.activityData)) {
      jsonMap['activity_data'] = activityData?.toJson();
    }
    if (_data.containsKey(AutoDetectedField.screenTimeData)) {
      jsonMap['screen_time_data'] = screenTimeData?.toJson();
    }
    if (_data.containsKey(AutoDetectedField.sleepDurationData)) {
      jsonMap['sleep_duration_data'] = sleepDurationData?.toJson();
    }
    if (_data.containsKey(AutoDetectedField.locationData)) {
      jsonMap['location_data'] = locationData?.toJson();
    }
    if (_data.containsKey(AutoDetectedField.heartRateData)) {
      jsonMap['heart_rate_data'] = heartRateData?.toJson();
    }

    return jsonMap;
  }

  // Set a field by enum
  void setField(AutoDetectedField field, dynamic value) {
    _data[field] = value;
  }

  // Get a field by enum
  dynamic getField(AutoDetectedField field) {
    return _data[field];
  }

  // Check if a field exists
  bool hasField(AutoDetectedField field) {
    return _data.containsKey(field);
  }

  AutoDetectedData copyWith({
    PhysicalActivityData? activityData,
    ScreenTimeData? screenTimeData,
    SleepDurationData? sleepDurationData,
    LocationData? locationData,
    HeartRateData? heartRateData,
  }) {
    final newData = AutoDetectedData();

    // Copy existing data
    newData._data.addAll(_data);

    // Update with new values if provided
    if (activityData != null) {
      newData._data[AutoDetectedField.activityData] = activityData;
    }
    if (screenTimeData != null) {
      newData._data[AutoDetectedField.screenTimeData] = screenTimeData;
    }
    if (sleepDurationData != null) {
      newData._data[AutoDetectedField.sleepDurationData] = sleepDurationData;
    }
    if (locationData != null) {
      newData._data[AutoDetectedField.locationData] = locationData;
    }
    if (heartRateData != null) {
      newData._data[AutoDetectedField.heartRateData] = heartRateData;
    }

    return newData;
  }
}

// Environmental data from APIs and external sources
class EnvironmentalData {
  // Map each enum field to its corresponding data
  final Map<EnvironmentalField, dynamic> _data = {};

  WeatherData? get weatherData =>
      _data[EnvironmentalField.weatherData] as WeatherData?;
  AirQualityData? get airQualityData =>
      _data[EnvironmentalField.airQualityData] as AirQualityData?;
  UVIndexData? get uvIndexData =>
      _data[EnvironmentalField.uvIndexData] as UVIndexData?;
  PollenData? get pollenData =>
      _data[EnvironmentalField.pollenData] as PollenData?;
  SeasonalData? get seasonalData =>
      _data[EnvironmentalField.seasonalData] as SeasonalData?;

  EnvironmentalData({
    WeatherData? weatherData,
    AirQualityData? airQualityData,
    UVIndexData? uvIndexData,
    PollenData? pollenData,
    SeasonalData? seasonalData,
  }) {
    if (weatherData != null) {
      _data[EnvironmentalField.weatherData] = weatherData;
    }
    if (airQualityData != null) {
      _data[EnvironmentalField.airQualityData] = airQualityData;
    }
    if (uvIndexData != null) {
      _data[EnvironmentalField.uvIndexData] = uvIndexData;
    }
    if (pollenData != null) {
      _data[EnvironmentalField.pollenData] = pollenData;
    }
    if (seasonalData != null) {
      _data[EnvironmentalField.seasonalData] = seasonalData;
    }
  }

  factory EnvironmentalData.fromJson(Map<String, dynamic> json) {
    return EnvironmentalData(
      weatherData: json['weather_data'] != null
          ? WeatherData.fromJson(json['weather_data'])
          : null,
      airQualityData: json['air_quality_data'] != null
          ? AirQualityData.fromJson(json['air_quality_data'])
          : null,
      uvIndexData: json['uv_index_data'] != null
          ? UVIndexData.fromJson(json['uv_index_data'])
          : null,
      pollenData: json['pollen_data'] != null
          ? PollenData.fromJson(json['pollen_data'])
          : null,
      seasonalData: json['seasonal_data'] != null
          ? SeasonalData.fromJson(json['seasonal_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final jsonMap = <String, dynamic>{};

    if (_data.containsKey(EnvironmentalField.weatherData)) {
      jsonMap['weather_data'] = weatherData?.toJson();
    }
    if (_data.containsKey(EnvironmentalField.airQualityData)) {
      jsonMap['air_quality_data'] = airQualityData?.toJson();
    }
    if (_data.containsKey(EnvironmentalField.uvIndexData)) {
      jsonMap['uv_index_data'] = uvIndexData?.toJson();
    }
    if (_data.containsKey(EnvironmentalField.pollenData)) {
      jsonMap['pollen_data'] = pollenData?.toJson();
    }
    if (_data.containsKey(EnvironmentalField.seasonalData)) {
      jsonMap['seasonal_data'] = seasonalData?.toJson();
    }

    return jsonMap;
  }

  // Set a field by enum
  void setField(EnvironmentalField field, dynamic value) {
    _data[field] = value;
  }

  // Get a field by enum
  dynamic getField(EnvironmentalField field) {
    return _data[field];
  }

  // Check if a field exists
  bool hasField(EnvironmentalField field) {
    return _data.containsKey(field);
  }

  EnvironmentalData copyWith({
    WeatherData? weatherData,
    AirQualityData? airQualityData,
    UVIndexData? uvIndexData,
    PollenData? pollenData,
    SeasonalData? seasonalData,
  }) {
    final newData = EnvironmentalData();

    // Copy existing data
    newData._data.addAll(_data);

    // Update with new values if provided
    if (weatherData != null) {
      newData._data[EnvironmentalField.weatherData] = weatherData;
    }
    if (airQualityData != null) {
      newData._data[EnvironmentalField.airQualityData] = airQualityData;
    }
    if (uvIndexData != null) {
      newData._data[EnvironmentalField.uvIndexData] = uvIndexData;
    }
    if (pollenData != null) {
      newData._data[EnvironmentalField.pollenData] = pollenData;
    }
    if (seasonalData != null) {
      newData._data[EnvironmentalField.seasonalData] = seasonalData;
    }

    return newData;
  }
}

class BloodPressure {
  final int systolic; // in mmHg
  final int diastolic; // in mmHg
  final DateTime timestamp;

  BloodPressure({
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
  });

  String get reading => '$systolic/$diastolic mmHg';

  String get category {
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'Hypertension Stage 1';
    if (systolic < 180 || diastolic < 120) return 'Hypertension Stage 2';
    return 'Hypertensive Crisis';
  }

  factory BloodPressure.fromJson(Map<String, dynamic> json) {
    return BloodPressure(
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class HealthCondition {
  final String name;
  final String? description;
  final DateTime? diagnosedDate;
  final bool isCurrent;

  HealthCondition({
    required this.name,
    this.description,
    this.diagnosedDate,
    this.isCurrent = true,
  });

  factory HealthCondition.fromJson(Map<String, dynamic> json) {
    return HealthCondition(
      name: json['name'],
      description: json['description'],
      diagnosedDate: json['diagnosed_date'] != null
          ? DateTime.parse(json['diagnosed_date'])
          : null,
      isCurrent: json['is_current'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'diagnosed_date': diagnosedDate?.toIso8601String(),
      'is_current': isCurrent,
    };
  }
}

class Medication {
  final String name;
  final String? dosage;
  final String? frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  Medication({
    required this.name,
    this.dosage,
    this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  bool get isActive => endDate == null || endDate!.isAfter(DateTime.now());

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'notes': notes,
    };
  }
}

class Allergy {
  final String name;
  final String? reaction;
  final String? severity; // Mild, Moderate, Severe

  Allergy({
    required this.name,
    this.reaction,
    this.severity,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      name: json['name'],
      reaction: json['reaction'],
      severity: json['severity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reaction': reaction,
      'severity': severity,
    };
  }
}

class SleepData {
  final double averageHoursPerNight;
  final int? qualityRating; // 1-10
  final String? sleepIssues;

  SleepData({
    required this.averageHoursPerNight,
    this.qualityRating,
    this.sleepIssues,
  });

  String get sleepQualityCategory {
    if (qualityRating == null) return 'Unknown';
    if (qualityRating! < 4) return 'Poor';
    if (qualityRating! < 7) return 'Average';
    return 'Good';
  }

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      averageHoursPerNight: json['average_hours_per_night']?.toDouble() ?? 0,
      qualityRating: json['quality_rating'],
      sleepIssues: json['sleep_issues'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_hours_per_night': averageHoursPerNight,
      'quality_rating': qualityRating,
      'sleep_issues': sleepIssues,
    };
  }
}

// AUTO-DETECTED DATA SUPPORT CLASSES

// HIGH PRIORITY - Daily activity tracking is essential for health monitoring
class PhysicalActivityData {
  final int steps; // HIGH PRIORITY - daily step count is a key metric
  final double caloriesBurned; // HIGH PRIORITY - daily calorie burn tracking
  final int activeMinutes; // HIGH PRIORITY - daily activity minutes
  final List<ActivitySession>?
      activitySessions; // HIGH PRIORITY - workouts and exercise tracking
  final DateTime date;

  PhysicalActivityData({
    required this.steps,
    required this.caloriesBurned,
    required this.activeMinutes,
    this.activitySessions,
    required this.date,
  });

  ActivityLevel get activityLevel {
    if (steps < 5000) return ActivityLevel.sedentary;
    if (steps < 7500) return ActivityLevel.lightlyActive;
    if (steps < 10000) return ActivityLevel.moderatelyActive;
    if (steps < 12500) return ActivityLevel.veryActive;
    return ActivityLevel.extremelyActive;
  }

  factory PhysicalActivityData.fromJson(Map<String, dynamic> json) {
    return PhysicalActivityData(
      steps: json['steps'] ?? 0,
      caloriesBurned: json['calories_burned']?.toDouble() ?? 0.0,
      activeMinutes: json['active_minutes'] ?? 0,
      activitySessions: json['activity_sessions'] != null
          ? List<ActivitySession>.from(
              json['activity_sessions'].map((x) => ActivitySession.fromJson(x)))
          : null,
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'calories_burned': caloriesBurned,
      'active_minutes': activeMinutes,
      'activity_sessions': activitySessions?.map((x) => x.toJson()).toList(),
      'date': date.toIso8601String(),
    };
  }
}

// HIGH PRIORITY - Daily workout tracking
class ActivitySession {
  final ExerciseType type;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double? intensity; // 0-1 scale
  final String?
      workoutImageUrl; // Optional image of workout (gym, running route, etc.)
  final List<String>? exercises; // Specific exercises performed

  ActivitySession({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.intensity,
    this.workoutImageUrl,
    this.exercises,
  });

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      type: ExerciseTypeExtension.fromJson(json['type']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      durationMinutes: json['duration_minutes'],
      intensity: json['intensity']?.toDouble(),
      workoutImageUrl: json['workout_image_url'],
      exercises: json['exercises'] != null
          ? List<String>.from(json['exercises'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'workout_image_url': workoutImageUrl,
      'exercises': exercises,
    };
  }
}

class ScreenTimeData {
  final int totalMinutes;
  final Map<String, int>? appUsageMinutes;
  final int? pickups;
  final int? notifications;
  final DateTime date;

  ScreenTimeData({
    required this.totalMinutes,
    this.appUsageMinutes,
    this.pickups,
    this.notifications,
    required this.date,
  });

  factory ScreenTimeData.fromJson(Map<String, dynamic> json) {
    Map<String, int>? appUsage;
    if (json['app_usage_minutes'] != null) {
      appUsage = Map<String, int>.from(json['app_usage_minutes']);
    }

    return ScreenTimeData(
      totalMinutes: json['total_minutes'] ?? 0,
      appUsageMinutes: appUsage,
      pickups: json['pickups'],
      notifications: json['notifications'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_minutes': totalMinutes,
      'app_usage_minutes': appUsageMinutes,
      'pickups': pickups,
      'notifications': notifications,
      'date': date.toIso8601String(),
    };
  }
}

class SleepDurationData {
  final DateTime bedtime;
  final DateTime wakeTime;
  final int durationMinutes;
  final Map<String, int>? sleepStageMinutes; // deep, light, REM, awake

  SleepDurationData({
    required this.bedtime,
    required this.wakeTime,
    required this.durationMinutes,
    this.sleepStageMinutes,
  });

  double get durationHours => durationMinutes / 60.0;

  factory SleepDurationData.fromJson(Map<String, dynamic> json) {
    Map<String, int>? sleepStages;
    if (json['sleep_stage_minutes'] != null) {
      sleepStages = Map<String, int>.from(json['sleep_stage_minutes']);
    }

    return SleepDurationData(
      bedtime: DateTime.parse(json['bedtime']),
      wakeTime: DateTime.parse(json['wake_time']),
      durationMinutes: json['duration_minutes'],
      sleepStageMinutes: sleepStages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedtime': bedtime.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'sleep_stage_minutes': sleepStageMinutes,
    };
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? placeName;
  final double? altitude;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.altitude,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      placeName: json['place_name'],
      altitude: json['altitude']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'place_name': placeName,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class HeartRateData {
  final int beatsPerMinute;
  final DateTime timestamp;
  final String? context; // rest, active, etc.

  HeartRateData({
    required this.beatsPerMinute,
    required this.timestamp,
    this.context,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
    return HeartRateData(
      beatsPerMinute: json['beats_per_minute'],
      timestamp: DateTime.parse(json['timestamp']),
      context: json['context'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beats_per_minute': beatsPerMinute,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }
}

extension ActivityLevelExtension on ActivityLevel {
  String toJson() => name;

  static ActivityLevel fromJson(String? json) {
    if (json == null) return ActivityLevel.sedentary;
    return ActivityLevel.values.firstWhere((e) => e.name == json,
        orElse: () => ActivityLevel.sedentary);
  }
}

extension ExerciseTypeExtension on ExerciseType {
  String toJson() => name;

  static ExerciseType fromJson(String? json) {
    if (json == null) return ExerciseType.other;
    return ExerciseType.values
        .firstWhere((e) => e.name == json, orElse: () => ExerciseType.other);
  }
}

// HIGH PRIORITY - Food tracking is a key feature for daily health
class NutritionData {
  final DietType? dietType;
  final List<String>? dietaryRestrictions;
  final int? dailyWaterIntake; // in ml - HIGH PRIORITY daily tracking
  final int? mealsPerDay;
  final List<FoodIntake>?
      recentMeals; // HIGH PRIORITY - main feature for food tracking with images

  NutritionData({
    this.dietType,
    this.dietaryRestrictions,
    this.dailyWaterIntake,
    this.mealsPerDay,
    this.recentMeals,
  });

  // Create a copy with updated fields
  NutritionData copyWith({
    DietType? dietType,
    List<String>? dietaryRestrictions,
    int? dailyWaterIntake,
    int? mealsPerDay,
    List<FoodIntake>? recentMeals,
  }) {
    return NutritionData(
      dietType: dietType ?? this.dietType,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      dailyWaterIntake: dailyWaterIntake ?? this.dailyWaterIntake,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      recentMeals: recentMeals ?? this.recentMeals,
    );
  }

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      dietType: json['diet_type'] != null
          ? DietTypeExtension.fromJson(json['diet_type'])
          : null,
      dietaryRestrictions: json['dietary_restrictions'] != null
          ? List<String>.from(json['dietary_restrictions'])
          : null,
      dailyWaterIntake: json['daily_water_intake'],
      mealsPerDay: json['meals_per_day'],
      recentMeals: json['recent_meals'] != null
          ? List<FoodIntake>.from(
              json['recent_meals'].map((x) => FoodIntake.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diet_type': dietType?.toJson(),
      'dietary_restrictions': dietaryRestrictions,
      'daily_water_intake': dailyWaterIntake,
      'meals_per_day': mealsPerDay,
      'recent_meals': recentMeals?.map((x) => x.toJson()).toList(),
    };
  }
}

// HIGH PRIORITY - Key feature for tracking daily food intake with images
class FoodIntake {
  final String description;
  final DateTime timestamp;
  final int? caloriesEstimate;
  final String? mealType; // Breakfast, Lunch, Dinner, Snack
  final String? imageUrl; // Store URL of food image uploaded by user
  final List<String>? ingredients; // Optional list of identified ingredients
  final Map<String, double>?
      nutritionalInfo; // Key-value pairs of nutrition facts

  FoodIntake({
    required this.description,
    required this.timestamp,
    this.caloriesEstimate,
    this.mealType,
    this.imageUrl,
    this.ingredients,
    this.nutritionalInfo,
  });

  factory FoodIntake.fromJson(Map<String, dynamic> json) {
    Map<String, double>? nutritionMap;
    if (json['nutritional_info'] != null) {
      nutritionMap = Map<String, double>.from(json['nutritional_info']);
    }

    return FoodIntake(
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      caloriesEstimate: json['calories_estimate'],
      mealType: json['meal_type'],
      imageUrl: json['image_url'],
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : null,
      nutritionalInfo: nutritionMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'calories_estimate': caloriesEstimate,
      'meal_type': mealType,
      'image_url': imageUrl,
      'ingredients': ingredients,
      'nutritional_info': nutritionalInfo,
    };
  }
}

class MoodData {
  final MoodLevel moodLevel;
  final List<String>? factors;
  final String? notes;
  final DateTime timestamp;

  MoodData({
    required this.moodLevel,
    this.factors,
    this.notes,
    required this.timestamp,
  });

  factory MoodData.fromJson(Map<String, dynamic> json) {
    return MoodData(
      moodLevel: MoodLevelExtension.fromJson(json['mood_level']),
      factors:
          json['factors'] != null ? List<String>.from(json['factors']) : null,
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood_level': moodLevel.toJson(),
      'factors': factors,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SymptomData {
  final List<Symptom> symptoms;
  final DateTime timestamp;

  SymptomData({
    required this.symptoms,
    required this.timestamp,
  });

  factory SymptomData.fromJson(Map<String, dynamic> json) {
    return SymptomData(
      symptoms:
          List<Symptom>.from(json['symptoms'].map((x) => Symptom.fromJson(x))),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symptoms': symptoms.map((x) => x.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Symptom {
  final String name;
  final int severity; // 1-10
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;

  Symptom({
    required this.name,
    required this.severity,
    required this.startTime,
    this.endTime,
    this.notes,
  });

  bool get isActive => endTime == null;

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      name: json['name'],
      severity: json['severity'],
      startTime: DateTime.parse(json['start_time']),
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'severity': severity,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'notes': notes,
    };
  }
}

class SleepQualityData {
  final int rating; // 1-10
  final List<String>? factors;
  final String? notes;
  final DateTime date;

  SleepQualityData({
    required this.rating,
    this.factors,
    this.notes,
    required this.date,
  });

  String get qualityCategory {
    if (rating < 4) {
      return 'Poor';
    }
    if (rating < 7) {
      return 'Average';
    }
    return 'Good';
  }

  factory SleepQualityData.fromJson(Map<String, dynamic> json) {
    return SleepQualityData(
      rating: json['rating'],
      factors:
          json['factors'] != null ? List<String>.from(json['factors']) : null,
      notes: json['notes'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'factors': factors,
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }
}

extension DietTypeExtension on DietType {
  String toJson() => name;

  static DietType fromJson(String? json) {
    if (json == null) return DietType.regular;
    return DietType.values
        .firstWhere((e) => e.name == json, orElse: () => DietType.regular);
  }
}

extension MoodLevelExtension on MoodLevel {
  String toJson() => name;

  static MoodLevel fromJson(String? json) {
    if (json == null) return MoodLevel.neutral;
    return MoodLevel.values
        .firstWhere((e) => e.name == json, orElse: () => MoodLevel.neutral);
  }
}

// ENVIRONMENTAL DATA SUPPORT CLASSES

class WeatherData {
  final double temperature; // in Celsius
  final double feelsLike;
  final int humidity; // percentage
  final double windSpeed; // in m/s
  final String condition; // clear, cloudy, rainy, etc.
  final DateTime timestamp;
  final String location;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.timestamp,
    required this.location,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      feelsLike: json['feels_like']?.toDouble() ?? 0.0,
      humidity: json['humidity'] ?? 0,
      windSpeed: json['wind_speed']?.toDouble() ?? 0.0,
      condition: json['condition'] ?? 'unknown',
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feels_like': feelsLike,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'condition': condition,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }
}

// HIGH PRIORITY - Daily air quality tracking (미세먼지)
class AirQualityData {
  final int aqi; // Air Quality Index
  final double pm25; // PM2.5 value (µg/m³) - HIGH PRIORITY (미세먼지 - fine dust)
  final double pm10; // PM10 value (µg/m³) - HIGH PRIORITY (미세먼지 - fine dust)
  final double? o3; // Ozone (ppb)
  final double? no2; // Nitrogen Dioxide (ppb)
  final double? so2; // Sulfur Dioxide (ppb)
  final double? co; // Carbon Monoxide (ppm)
  final DateTime timestamp;
  final String location;

  AirQualityData({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    this.o3,
    this.no2,
    this.so2,
    this.co,
    required this.timestamp,
    required this.location,
  });

  String get aqiCategory {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      aqi: json['aqi'] ?? 0,
      pm25: json['pm25']?.toDouble() ?? 0.0,
      pm10: json['pm10']?.toDouble() ?? 0.0,
      o3: json['o3']?.toDouble(),
      no2: json['no2']?.toDouble(),
      so2: json['so2']?.toDouble(),
      co: json['co']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi,
      'pm25': pm25,
      'pm10': pm10,
      'o3': o3,
      'no2': no2,
      'so2': so2,
      'co': co,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }
}

class UVIndexData {
  final double uvIndex;
  final String riskLevel; // Low, Moderate, High, Very High, Extreme
  final Map<String, String>? protectionAdvice;
  final DateTime timestamp;
  final String location;

  UVIndexData({
    required this.uvIndex,
    required this.riskLevel,
    this.protectionAdvice,
    required this.timestamp,
    required this.location,
  });

  factory UVIndexData.fromJson(Map<String, dynamic> json) {
    Map<String, String>? advice;
    if (json['protection_advice'] != null) {
      advice = Map<String, String>.from(json['protection_advice']);
    }

    return UVIndexData(
      uvIndex: json['uv_index']?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] ?? 'Unknown',
      protectionAdvice: advice,
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uv_index': uvIndex,
      'risk_level': riskLevel,
      'protection_advice': protectionAdvice,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }
}

class PollenData {
  final int treePollenLevel; // 0-5 scale
  final int grassPollenLevel; // 0-5 scale
  final int weedPollenLevel; // 0-5 scale
  final int moldLevel; // 0-5 scale
  final DateTime timestamp;
  final String location;

  PollenData({
    required this.treePollenLevel,
    required this.grassPollenLevel,
    required this.weedPollenLevel,
    required this.moldLevel,
    required this.timestamp,
    required this.location,
  });

  String getPollenCategory(int level) {
    if (level == 0) return 'None';
    if (level == 1) return 'Very Low';
    if (level == 2) return 'Low';
    if (level == 3) return 'Medium';
    if (level == 4) return 'High';
    return 'Very High';
  }

  factory PollenData.fromJson(Map<String, dynamic> json) {
    return PollenData(
      treePollenLevel: json['tree_pollen_level'] ?? 0,
      grassPollenLevel: json['grass_pollen_level'] ?? 0,
      weedPollenLevel: json['weed_pollen_level'] ?? 0,
      moldLevel: json['mold_level'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tree_pollen_level': treePollenLevel,
      'grass_pollen_level': grassPollenLevel,
      'weed_pollen_level': weedPollenLevel,
      'mold_level': moldLevel,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }
}

class SeasonalData {
  final Season currentSeason;
  final bool isAllergySeason;
  final bool isFluSeason;
  final List<String>? seasonalAdvice;
  final DateTime timestamp;
  final String location;

  SeasonalData({
    required this.currentSeason,
    required this.isAllergySeason,
    required this.isFluSeason,
    this.seasonalAdvice,
    required this.timestamp,
    required this.location,
  });

  factory SeasonalData.fromJson(Map<String, dynamic> json) {
    return SeasonalData(
      currentSeason: SeasonExtension.fromJson(json['current_season']),
      isAllergySeason: json['is_allergy_season'] ?? false,
      isFluSeason: json['is_flu_season'] ?? false,
      seasonalAdvice: json['seasonal_advice'] != null
          ? List<String>.from(json['seasonal_advice'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_season': currentSeason.toJson(),
      'is_allergy_season': isAllergySeason,
      'is_flu_season': isFluSeason,
      'seasonal_advice': seasonalAdvice,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }
}

extension SeasonExtension on Season {
  String toJson() => name;

  static Season fromJson(String? json) {
    if (json == null) return Season.spring;
    return Season.values
        .firstWhere((e) => e.name == json, orElse: () => Season.spring);
  }
}

// Add this method to demonstrate the usage of the new enum-based approach
void demonstrateEnumBasedApproach() {
  // Create a new user input data object with just a few fields
  final userData = UserInputData()
    ..setField(UserInputField.height, 180.0)
    ..setField(UserInputField.weight, 75.0);

  // Add mood data later
  userData.setField(
      UserInputField.moodData,
      MoodData(
          moodLevel: MoodLevel.positive,
          factors: ['Exercise', 'Good sleep'],
          timestamp: DateTime.now()));

  // Check if a field exists
  if (userData.hasField(UserInputField.height)) {
    print('Height is ${userData.height} cm');
  }

  // Create environmental data
  final envData = EnvironmentalData();
  envData.setField(
      EnvironmentalField.weatherData,
      WeatherData(
          temperature: 25.0,
          feelsLike: 26.0,
          humidity: 65,
          windSpeed: 5.0,
          condition: 'Sunny',
          timestamp: DateTime.now(),
          location: 'Seoul'));

  // Create a complete health metrics object
  final healthMetrics = HealthMetrics(
      userInputData: userData,
      autoDetectedData: AutoDetectedData(),
      environmentalData: envData);

  // Convert to JSON and back
  final json = healthMetrics.toJson();
  final recreated = HealthMetrics.fromJson(json);
}
