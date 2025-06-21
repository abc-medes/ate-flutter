import 'package:flutter_riverpod/flutter_riverpod.dart'; // Or your chosen state management
import 'package:ate_project/data/models/health_model.dart';
import 'package:ate_project/data/models/body_simulator_model.dart'; // Ensure this path and model are correct

// Provider for the ViewModel
final bodySimulatorViewModelProvider =
    StateNotifierProvider<BodySimulatorViewModel, AsyncValue<HealthMetrics>>(
        (ref) {
  return BodySimulatorViewModel(ref);
});

class BodySimulatorViewModel extends StateNotifier<AsyncValue<HealthMetrics>> {
  final Ref _ref; // Keep a reference to Ref if you need to read other providers

  BodySimulatorViewModel(this._ref) : super(const AsyncValue.loading()) {
    _loadHealthMetrics();
  }

  Future<void> _loadHealthMetrics() async {
    state = const AsyncValue.loading();
    try {
      // For demonstration, creating sample HealthMetrics data:
      BodySimulatorData simData = BodySimulatorData(
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          state: BodySimulatorState(
            brain: BrainData(
                stressLevel: 0.3,
                serotonin: 0.6,
                sleepRhythm: 0.8,
                cortisol: 0.4),
            heart: HeartData(
                bloodSugar: 90.0,
                bloodPressure: 120.0,
                heartRate: 65.0,
                hrv: 55.0),
            lungs: LungsData(
                oxygenSaturation: 98.0,
                lungHealth: 0.9,
                pmExposure: 0.2,
                respiratoryRate: 16.0),
            liver: LiverData(
                detoxCapacity: 0.85,
                liverEnzymes: 25.0,
                fatProcessing: 0.75,
                alcoholLoad: 0.1),
            stomach: StomachData(
                digestionSpeed: 1.0,
                acidity: 2.5,
                nauseaRisk: 0.1,
                foodRetention: 3.0),
            intestines: IntestinesData(
                gutBacteriaDiversity: 0.7,
                inflammation: 0.15,
                absorptionRate: 0.9,
                gasLevel: 0.2),
            kidneys: KidneysData(
                hydration: 0.8,
                electrolyteBalance: 0.9,
                ureaClearance: 0.7,
                toxicityLoad: 0.1),
            endocrine: EndocrineData(
                insulinSensitivity: 0.8,
                thyroidFunction: 0.9,
                estrogenTestosteroneRatio: 1.2),
            nervous: NervousData(
                focusLevel: 0.75,
                moodStability: 0.8,
                anxietyLevel: 0.2,
                neuroFlexibility: 0.65),
          ));

      // Or if you want to start with an empty simulation:
      // BodySimulatorData simData = BodySimulatorData.empty();

      final sampleMetrics = HealthMetrics(
        userInputData: UserInputData(
            height: 175,
            weight: 70,
            dateOfBirth: DateTime(1990, 1, 15),
            gender: "Male",
            allergies: [Allergy(name: "Pollen", severity: "Moderate")],
            nutritionData: NutritionData(
                dietType: DietType.mediterranean,
                dailyWaterIntake: 2000,
                recentMeals: [
                  FoodIntake(
                      description: "Lunch: Salad with Chicken",
                      timestamp:
                          DateTime.now().subtract(const Duration(hours: 3)),
                      mealType: "Lunch",
                      caloriesEstimate: 550,
                      ingredients: [
                        "Lettuce",
                        "Chicken Breast",
                        "Tomato",
                        "Cucumber",
                        "Olive Oil"
                      ],
                      nutritionalInfo: {
                        "protein": 30,
                        "carbs": 15,
                        "fat": 20
                      }),
                ]),
            moodData: MoodData(
                moodLevel: MoodLevel.positive,
                factors: ["Good Sleep", "Exercise"],
                timestamp: DateTime.now().subtract(const Duration(hours: 1))),
            symptoms: SymptomData(symptoms: [
              Symptom(
                  name: "Slight Headache",
                  severity: 2,
                  startTime:
                      DateTime.now().subtract(const Duration(minutes: 30)))
            ], timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
            sleepQuality: SleepQualityData(
                rating: 8,
                factors: ["Quiet Room"],
                date: DateTime.now().subtract(const Duration(days: 1)))),
        autoDetectedData: AutoDetectedData(
            activityData: PhysicalActivityData(
                steps: 8500,
                caloriesBurned: 450,
                activeMinutes: 75,
                date: DateTime.now().subtract(const Duration(days: 1)),
                activitySessions: [
                  ActivitySession(
                      type: ExerciseType.running,
                      startTime:
                          DateTime.now().subtract(const Duration(hours: 20)),
                      endTime: DateTime.now()
                          .subtract(const Duration(hours: 19, minutes: 30)),
                      durationMinutes: 30,
                      intensity: 0.7)
                ]),
            sleepDurationData: SleepDurationData(
                bedtime: DateTime.now().subtract(const Duration(hours: 9)),
                wakeTime: DateTime.now().subtract(const Duration(hours: 1)),
                durationMinutes: (8 * 60), // 8 hours
                sleepStageMinutes: {
                  "deep": 120,
                  "light": 240,
                  "rem": 100,
                  "awake": 20
                }),
            heartRateData: HeartRateData(
                beatsPerMinute: 65,
                timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
                context: "resting"),
            screenTimeData: ScreenTimeData(
                totalMinutes: 240,
                date: DateTime.now().subtract(const Duration(days: 1)),
                appUsageMinutes: {"SocialMediaApp": 60, "WorkApp": 120})),
        environmentalData: EnvironmentalData(
            weatherData: WeatherData(
                temperature: 18.5,
                feelsLike: 17.0,
                humidity: 60,
                windSpeed: 3.5,
                condition: "Cloudy",
                timestamp: DateTime.now(),
                location: "My City"),
            airQualityData: AirQualityData(
                aqi: 55,
                pm25: 12.1,
                pm10: 18.3,
                timestamp: DateTime.now(),
                location: "My City"),
            uvIndexData: UVIndexData(
                uvIndex: 2,
                riskLevel: "Low",
                timestamp: DateTime.now(),
                location: "My City"),
            pollenData: PollenData(
                treePollenLevel: 1,
                grassPollenLevel: 2,
                weedPollenLevel: 0,
                moldLevel: 1,
                timestamp: DateTime.now(),
                location: "My City"),
            seasonalData: SeasonalData(
                currentSeason: Season.spring,
                isAllergySeason: true,
                isFluSeason: false,
                timestamp: DateTime.now(),
                location: "My City")),
        bodySimulatorData: simData,
      );
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      state = AsyncValue.data(sampleMetrics);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      // Consider logging the error to a service
    }
  }

  // You can add methods here to update health metrics or trigger simulations
  // For example:
  // Future<void> runSimulation() async {
  //   // ... logic to interact with a simulation service ...
  //   _loadHealthMetrics(); // Refresh data after simulation
  // }
}
