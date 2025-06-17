import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/core/widgets/chat_input.dart';
import 'package:ate_project/features/body_simulator/view_models/body_simulator_view_model.dart';
import 'package:ate_project/features/body_simulator/views/widgets/heart_painter.dart';
import 'package:ate_project/features/home/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:ate_project/data/models/health_model.dart';
import 'package:ate_project/data/models/body_simulator_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class BodySimulatorView extends ConsumerStatefulWidget {
  // Constructor no longer needs healthMetrics directly
  const BodySimulatorView({Key? key}) : super(key: key);

  @override
  ConsumerState<BodySimulatorView> createState() => _BodySimulatorViewState();
}

class _BodySimulatorViewState extends ConsumerState<BodySimulatorView> {
  final TextEditingController _chatController = TextEditingController();
  bool _isSaveMode = false;
  late final Future<LottieComposition> _composition;

  @override
  void initState() {
    super.initState();
    _composition = AssetLottie('assets/organs/lottie/kidney.json').load();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncHealthMetrics = ref.watch(bodySimulatorViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Body Simulator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: asyncHealthMetrics.when(
              data: (healthMetrics) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 128,
                        height: 128,
                        child: Lottie.asset(
                          'assets/organs/beating_pixel_heart.json',
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.none,
                        ),
                      ),

                      // SVG render placeholder for testing
                      SizedBox(
                        height: 120,
                        child: SvgPicture.string(
                          '''<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="grey" stroke-width="12">
                                      <path d="M 251 55 L 247 59 L 246 229 L 225 237 L 223 236 L 225 193 L 230 167 L 229 149 L 220 131 L 211 123 L 201 119 L 181 119 L 165 122 L 151 127 L 128 140 L 98 170 L 78 208 L 69 249 L 69 438 L 72 450 L 78 461 L 88 471 L 97 476 L 115 478 L 127 474 L 206 413 L 220 398 L 227 384 L 231 368 L 224 251 L 226 251 L 226 254 L 228 250 L 227 245 L 250 236 L 278 247 L 271 368 L 276 387 L 288 406 L 375 474 L 383 477 L 397 478 L 409 474 L 423 462 L 429 452 L 433 438 L 433 251 L 427 218 L 419 196 L 410 179 L 395 159 L 368 136 L 340 123 L 321 119 L 301 119 L 291 123 L 280 133 L 272 154 L 264 156 L 258 166 L 258 171 L 263 180 L 275 182 L 278 208 L 278 236 L 276 237 L 256 229 L 255 60 Z"/>
                                    </svg>''',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      // PNG image render box for testing
                      SizedBox(
                        height: 120,
                        child: Image.asset(
                          'assets/organs/brain.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const HeartHealthScreen(),
                      _buildSectionTitle('Overall Health Summary'),
                      _buildOverallSummary(healthMetrics),
                      const SizedBox(height: 20),
                      _buildSectionTitle('User Provided Data'),
                      _buildUserInputDataSection(healthMetrics.userInputData),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Automatically Detected Data'),
                      _buildAutoDetectedDataSection(
                          healthMetrics.autoDetectedData),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Environmental Factors'),
                      _buildEnvironmentalDataSection(
                          healthMetrics.environmentalData),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Body Simulation Insights'),
                      _buildBodySimulatorDataSection(
                          context, healthMetrics.bodySimulatorData),
                    ],
                  ),
                );
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
              error: (error, stackTrace) {
                debugPrint('Error in BodySimulatorView: $error\n$stackTrace');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Failed to load health data. Please try again later.\nError: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ChatInput(
              controller: _chatController,
              shouldSaveAsContext: _isSaveMode,
              onSaveModeToggle: () {
                setState(() {
                  _isSaveMode = !_isSaveMode;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Save mode toggled: $_isSaveMode')),
                );
              },
              onSubmit: (text, images) {
                if (text.isNotEmpty) {
                  final homeViewModel =
                      ref.read(homeViewModelProvider.notifier);

                  homeViewModel.textController.text = text;

                  if (_isSaveMode) {
                    homeViewModel.handleMemorize(context);
                  } else {
                    homeViewModel.handleChatSubmit();
                  }

                  _chatController.clear();

                  context.go(RouteNames.home);
                }
              },
              // isDisabled: asyncHealthMetrics.isLoading, // Optionally disable while loading
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOverallSummary(HealthMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow('Age', metrics.age?.toString() ?? 'N/A'),
            _buildDataRow('BMI', metrics.bmi?.toStringAsFixed(1) ?? 'N/A'),
            _buildDataRow('BMI Category', metrics.bmiCategory ?? 'N/A'),
            _buildDataRow('Basic Profile Complete',
                metrics.isBasicProfileComplete ? 'Yes' : 'No'),
            if (metrics.homeSuggestions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Suggestions:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              for (var suggestion in metrics.homeSuggestions)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                  child: Text('• $suggestion'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value,
      {bool isSubItem = false, TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: isSubItem ? 2.0 : 4.0, horizontal: isSubItem ? 16.0 : 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }

  Widget _buildNullSafeText(String label, dynamic value,
      {String defaultValue = 'N/A', bool isSubItem = false, String? unit}) {
    String displayValue = value?.toString() ?? defaultValue;
    if (value != null && unit != null) {
      displayValue += ' $unit';
    }
    return _buildDataRow(label, displayValue, isSubItem: isSubItem);
  }

  Widget _buildUserInputDataSection(UserInputData data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNullSafeText('Height', data.height, unit: 'cm'),
            _buildNullSafeText('Weight', data.weight, unit: 'kg'),
            _buildNullSafeText('Date of Birth',
                data.dateOfBirth?.toIso8601String().substring(0, 10)),
            _buildNullSafeText('Gender', data.gender),
            _buildDataList('Pre-existing Conditions',
                data.preExistingConditions?.map((c) => c.name).toList()),
            _buildDataList(
                'Medications', data.medications?.map((m) => m.name).toList()),
            _buildDataList(
                'Allergies', data.allergies?.map((a) => a.name).toList()),
            _buildNullSafeText('Memorized Data', data.memorizedData),
            if (data.nutritionData != null)
              _buildNutritionData(data.nutritionData!),
            if (data.moodData != null) _buildMoodData(data.moodData!),
            if (data.symptoms != null) _buildSymptomData(data.symptoms!),
            if (data.sleepQuality != null)
              _buildSleepQualityData(data.sleepQuality!),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoDetectedDataSection(AutoDetectedData data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.activityData != null)
              _buildPhysicalActivityData(data.activityData!)
            else
              _buildExpansionTilePlaceholder("Physical Activity Data"),
            if (data.screenTimeData != null)
              _buildScreenTimeData(data.screenTimeData!)
            else
              _buildExpansionTilePlaceholder("Screen Time Data"),
            if (data.sleepDurationData != null)
              _buildSleepDurationData(data.sleepDurationData!)
            else
              _buildExpansionTilePlaceholder("Sleep Duration Data"),
            if (data.locationData != null)
              _buildLocationData(data.locationData!)
            else
              _buildExpansionTilePlaceholder("Location Data"),
            if (data.heartRateData != null)
              _buildHeartRateData(data.heartRateData!)
            else
              _buildExpansionTilePlaceholder("Heart Rate Data"),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalDataSection(EnvironmentalData data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.weatherData != null)
              _buildWeatherData(data.weatherData!)
            else
              _buildExpansionTilePlaceholder("Weather Data"),
            if (data.airQualityData != null)
              _buildAirQualityData(data.airQualityData!)
            else
              _buildExpansionTilePlaceholder("Air Quality Data"),
            if (data.uvIndexData != null)
              _buildUVIndexData(data.uvIndexData!)
            else
              _buildExpansionTilePlaceholder("UV Index Data"),
            if (data.pollenData != null)
              _buildPollenData(data.pollenData!)
            else
              _buildExpansionTilePlaceholder("Pollen Data"),
            if (data.seasonalData != null)
              _buildSeasonalData(data.seasonalData!)
            else
              _buildExpansionTilePlaceholder("Seasonal Data"),
          ],
        ),
      ),
    );
  }

  Widget _buildBodySimulatorDataSection(
      BuildContext context, BodySimulatorData data) {
    final state = data.state;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNullSafeText(
                'Last Updated',
                data.lastUpdatedAt
                        ?.toLocal()
                        .toIso8601String()
                        .substring(0, 16)
                        .replaceFirst('T', ' ') ??
                    "Not yet simulated"),
            const SizedBox(height: 10),
            if (state.brain != null) _buildBrainDataSection(state.brain!),
            if (state.heart != null) _buildHeartDataSection(state.heart!),
            if (state.lungs != null) _buildLungsDataSection(state.lungs!),
            if (state.liver != null) _buildLiverDataSection(state.liver!),
            if (state.stomach != null) _buildStomachDataSection(state.stomach!),
            if (state.intestines != null)
              _buildIntestinesDataSection(state.intestines!),
            if (state.kidneys != null) _buildKidneysDataSection(state.kidneys!),
            if (state.endocrine != null)
              _buildEndocrineDataSection(state.endocrine!),
            if (state.nervous != null) _buildNervousDataSection(state.nervous!),
            if (state.brain == null &&
                state.heart == null &&
                state.lungs == null &&
                state.liver == null &&
                state.stomach == null &&
                state.intestines == null &&
                state.kidneys == null &&
                state.endocrine == null &&
                state.nervous == null &&
                data.lastUpdatedAt == null)
              const Center(
                  child: Text("No body simulation data available yet.")),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganSection<T>(
      String title, T? organData, List<Widget> Function(T data) builder) {
    if (organData == null) {
      return ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: const [
          Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No data available for this organ."))
        ],
      );
    }
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
      initiallyExpanded: false, // Keep them closed by default to avoid clutter
      children: builder(organData),
    );
  }

  Widget _buildBrainDataSection(BrainData data) {
    return _buildOrganSection(
        "Brain",
        data,
        (d) => [
              _buildNullSafeText(
                  'Stress Level', d.stressLevel.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText('Serotonin', d.serotonin.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Sleep Rhythm Score', d.sleepRhythm.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText('Cortisol', d.cortisol.toStringAsFixed(2),
                  isSubItem: true),
            ]);
  }

  Widget _buildHeartDataSection(HeartData data) {
    return _buildOrganSection(
        "Heart",
        data,
        (d) => [
              _buildNullSafeText('Blood Sugar', d.bloodSugar.toStringAsFixed(2),
                  unit: 'mg/dL', isSubItem: true),
              _buildNullSafeText(
                  'Blood Pressure', d.bloodPressure.toStringAsFixed(0),
                  unit: 'mmHg (avg)',
                  isSubItem: true), // Assuming it's an average or single value
              _buildNullSafeText('Heart Rate', d.heartRate.toStringAsFixed(0),
                  unit: 'bpm', isSubItem: true),
              _buildNullSafeText(
                  'HRV (Heart Rate Variability)', d.hrv.toStringAsFixed(2),
                  unit: 'ms', isSubItem: true),
            ]);
  }

  Widget _buildLungsDataSection(LungsData data) {
    return _buildOrganSection(
        "Lungs",
        data,
        (d) => [
              _buildNullSafeText(
                  'Oxygen Saturation', d.oxygenSaturation.toStringAsFixed(1),
                  unit: '%', isSubItem: true),
              _buildNullSafeText(
                  'Lung Health Score', d.lungHealth.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'PM Exposure Index', d.pmExposure.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Respiratory Rate', d.respiratoryRate.toStringAsFixed(0),
                  unit: 'breaths/min', isSubItem: true),
            ]);
  }

  Widget _buildLiverDataSection(LiverData data) {
    return _buildOrganSection(
        "Liver",
        data,
        (d) => [
              _buildNullSafeText(
                  'Detox Capacity Score', d.detoxCapacity.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Liver Enzymes Level', d.liverEnzymes.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText('Fat Processing Efficiency',
                  d.fatProcessing.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Alcohol Load Index', d.alcoholLoad.toStringAsFixed(2),
                  isSubItem: true),
            ]);
  }

  Widget _buildStomachDataSection(StomachData data) {
    return _buildOrganSection(
        "Stomach",
        data,
        (d) => [
              _buildNullSafeText(
                  'Digestion Speed Factor', d.digestionSpeed.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Acidity Level (pH avg)', d.acidity.toStringAsFixed(1),
                  isSubItem: true),
              _buildNullSafeText('Nausea Risk', d.nauseaRisk.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Food Retention Time', d.foodRetention.toStringAsFixed(1),
                  unit: 'hours', isSubItem: true),
            ]);
  }

  Widget _buildIntestinesDataSection(IntestinesData data) {
    return _buildOrganSection(
        "Intestines",
        data,
        (d) => [
              _buildNullSafeText('Gut Bacteria Diversity Score',
                  d.gutBacteriaDiversity.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Inflammation Level', d.inflammation.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText('Nutrient Absorption Rate',
                  d.absorptionRate.toStringAsFixed(2),
                  unit: '%', isSubItem: true),
              _buildNullSafeText(
                  'Gas Level Index', d.gasLevel.toStringAsFixed(2),
                  isSubItem: true),
            ]);
  }

  Widget _buildKidneysDataSection(KidneysData data) {
    return _buildOrganSection(
        "Kidneys",
        data,
        (d) => [
              _buildNullSafeText(
                  'Hydration Level', d.hydration.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText('Electrolyte Balance Score',
                  d.electrolyteBalance.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Urea Clearance Rate', d.ureaClearance.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Toxicity Load Index', d.toxicityLoad.toStringAsFixed(2),
                  isSubItem: true),
            ]);
  }

  Widget _buildEndocrineDataSection(EndocrineData data) {
    return _buildOrganSection(
        "Endocrine System",
        data,
        (d) => [
              _buildNullSafeText('Insulin Sensitivity Score',
                  d.insulinSensitivity.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText('Thyroid Function Score',
                  d.thyroidFunction.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText('Estrogen/Testosterone Ratio',
                  d.estrogenTestosteroneRatio.toStringAsFixed(2),
                  isSubItem: true),
            ]);
  }

  Widget _buildNervousDataSection(NervousData data) {
    return _buildOrganSection(
        "Nervous System",
        data,
        (d) => [
              _buildNullSafeText('Focus Level', d.focusLevel.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Mood Stability Score', d.moodStability.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText(
                  'Anxiety Level', d.anxietyLevel.toStringAsFixed(2),
                  isSubItem: true),
              _buildNullSafeText('Neuro Flexibility Score',
                  d.neuroFlexibility.toStringAsFixed(2),
                  isSubItem: true),
            ]);
  }

  Widget _buildExpansionTilePlaceholder(String title) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: const [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available.'),
        )
      ],
    );
  }

  Widget _buildDataList(String label, List<String>? items) {
    if (items == null || items.isEmpty) {
      return _buildNullSafeText(label, 'None');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Text('• $item')).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataMap(String label, Map<String, dynamic> items) {
    if (items.isEmpty) {
      return _buildNullSafeText(label, 'None');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.entries
                  .map((entry) => _buildDataRow(
                      entry.key, entry.value.toString(),
                      isSubItem: true))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionData(NutritionData data) {
    return ExpansionTile(
      title: const Text('Nutrition Data',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Diet Type', data.dietType?.toString().split('.').last,
            isSubItem: true),
        _buildDataList('Dietary Restrictions', data.dietaryRestrictions),
        _buildNullSafeText('Daily Water Intake', data.dailyWaterIntake,
            unit: 'ml', isSubItem: true),
        _buildNullSafeText('Meals Per Day', data.mealsPerDay, isSubItem: true),
        if (data.recentMeals != null && data.recentMeals!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 4.0, left: 16.0),
            child: Text('Recent Meals:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (var meal in data.recentMeals!) _buildFoodIntake(meal),
        ] else
          _buildNullSafeText('Recent Meals', 'None logged', isSubItem: true),
      ],
    );
  }

  Widget _buildFoodIntake(FoodIntake meal) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, bottom: 8.0, top: 4.0), // Adjusted padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meal.description,
              style: const TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
          _buildNullSafeText('Type', meal.mealType, isSubItem: true),
          _buildNullSafeText('Calories Est.', meal.caloriesEstimate,
              isSubItem: true),
          _buildNullSafeText(
              'Timestamp',
              meal.timestamp
                  .toLocal()
                  .toIso8601String()
                  .substring(0, 16)
                  .replaceFirst('T', ' '),
              isSubItem: true),
          if (meal.imageUrl != null)
            _buildNullSafeText('Image', meal.imageUrl, isSubItem: true),
          _buildDataList('Ingredients', meal.ingredients),
          if (meal.nutritionalInfo != null && meal.nutritionalInfo!.isNotEmpty)
            _buildDataMap('Nutritional Info', meal.nutritionalInfo!),
        ],
      ),
    );
  }

  Widget _buildMoodData(MoodData data) {
    return ExpansionTile(
      title: const Text('Mood Data',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText('Level', data.moodLevel.toString().split('.').last,
            isSubItem: true),
        _buildDataList('Factors', data.factors),
        _buildNullSafeText('Notes', data.notes, isSubItem: true),
        _buildNullSafeText(
            'Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
      ],
    );
  }

  Widget _buildSymptomData(SymptomData data) {
    return ExpansionTile(
      title: const Text('Symptom Data',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Log Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        if (data.symptoms.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 4.0, left: 16.0),
            child: Text('Symptoms:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (var symptom in data.symptoms) _buildSymptom(symptom),
        ] else
          _buildNullSafeText('Symptoms', 'None logged', isSubItem: true),
      ],
    );
  }

  Widget _buildSymptom(Symptom symptom) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(symptom.name,
              style: const TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
          _buildNullSafeText('Severity (1-10)', symptom.severity,
              isSubItem: true),
          _buildNullSafeText(
              'Start Time',
              symptom.startTime
                  .toLocal()
                  .toIso8601String()
                  .substring(0, 16)
                  .replaceFirst('T', ' '),
              isSubItem: true),
          _buildNullSafeText(
              'End Time',
              symptom.endTime
                  ?.toLocal()
                  .toIso8601String()
                  .substring(0, 16)
                  .replaceFirst('T', ' '),
              isSubItem: true),
          _buildNullSafeText('Notes', symptom.notes, isSubItem: true),
          _buildNullSafeText('Active', symptom.isActive ? 'Yes' : 'No',
              isSubItem: true),
        ],
      ),
    );
  }

  Widget _buildSleepQualityData(SleepQualityData data) {
    return ExpansionTile(
      title: const Text('Sleep Quality Data',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText('Date', data.date.toIso8601String().substring(0, 10),
            isSubItem: true),
        _buildNullSafeText('Rating (1-10)', data.rating, isSubItem: true),
        _buildNullSafeText('Category', data.qualityCategory, isSubItem: true),
        _buildDataList('Factors', data.factors),
        _buildNullSafeText('Notes', data.notes, isSubItem: true),
      ],
    );
  }

  Widget _buildPhysicalActivityData(PhysicalActivityData data) {
    return ExpansionTile(
      title: const Text('Physical Activity',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText('Date', data.date.toIso8601String().substring(0, 10),
            isSubItem: true),
        _buildNullSafeText('Steps', data.steps, isSubItem: true),
        _buildNullSafeText(
            'Calories Burned', data.caloriesBurned.toStringAsFixed(1),
            isSubItem: true),
        _buildNullSafeText('Active Minutes', data.activeMinutes,
            isSubItem: true),
        _buildNullSafeText(
            'Activity Level', data.activityLevel.toString().split('.').last,
            isSubItem: true),
        if (data.activitySessions != null &&
            data.activitySessions!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 4.0, left: 16.0),
            child: Text('Activity Sessions:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (var session in data.activitySessions!)
            _buildActivitySession(session),
        ] else
          _buildNullSafeText('Activity Sessions', 'None logged',
              isSubItem: true),
      ],
    );
  }

  Widget _buildActivitySession(ActivitySession session) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${session.type.toString().split('.').last}',
              style: const TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
          _buildNullSafeText('Duration', session.durationMinutes,
              unit: 'min', isSubItem: true),
          _buildNullSafeText(
              'Start',
              session.startTime
                  .toLocal()
                  .toIso8601String()
                  .substring(0, 16)
                  .replaceFirst('T', ' '),
              isSubItem: true),
          _buildNullSafeText(
              'End',
              session.endTime
                  .toLocal()
                  .toIso8601String()
                  .substring(0, 16)
                  .replaceFirst('T', ' '),
              isSubItem: true),
          _buildNullSafeText(
              'Intensity (0-1)', session.intensity?.toStringAsFixed(1),
              isSubItem: true),
          _buildDataList('Exercises', session.exercises),
          if (session.workoutImageUrl != null)
            _buildNullSafeText('Image URL', session.workoutImageUrl,
                isSubItem: true),
        ],
      ),
    );
  }

  Widget _buildScreenTimeData(ScreenTimeData data) {
    return ExpansionTile(
      title: const Text('Screen Time',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText('Date', data.date.toIso8601String().substring(0, 10),
            isSubItem: true),
        _buildNullSafeText('Total Minutes', data.totalMinutes, isSubItem: true),
        _buildNullSafeText('Pickups', data.pickups, isSubItem: true),
        _buildNullSafeText('Notifications', data.notifications,
            isSubItem: true),
        if (data.appUsageMinutes != null && data.appUsageMinutes!.isNotEmpty)
          _buildDataMap('App Usage (minutes)', data.appUsageMinutes!),
      ],
    );
  }

  Widget _buildSleepDurationData(SleepDurationData data) {
    return ExpansionTile(
      title: const Text('Sleep Duration',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Bedtime',
            data.bedtime
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText(
            'Wake Time',
            data.wakeTime
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText('Duration', data.durationHours.toStringAsFixed(1),
            unit: 'hours', isSubItem: true),
        if (data.sleepStageMinutes != null &&
            data.sleepStageMinutes!.isNotEmpty)
          _buildDataMap('Sleep Stages (minutes)', data.sleepStageMinutes!),
      ],
    );
  }

  Widget _buildLocationData(LocationData data) {
    return ExpansionTile(
      title: const Text('Location Data',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText('Latitude', data.latitude.toStringAsFixed(5),
            isSubItem: true),
        _buildNullSafeText('Longitude', data.longitude.toStringAsFixed(5),
            isSubItem: true),
        _buildNullSafeText('Place Name', data.placeName, isSubItem: true),
        _buildNullSafeText('Altitude', data.altitude?.toStringAsFixed(1),
            unit: 'm', isSubItem: true),
      ],
    );
  }

  Widget _buildHeartRateData(HeartRateData data) {
    return ExpansionTile(
      title: const Text('Heart Rate',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText('BPM', data.beatsPerMinute, isSubItem: true),
        _buildNullSafeText('Context', data.context, isSubItem: true),
      ],
    );
  }

  Widget _buildWeatherData(WeatherData data) {
    return ExpansionTile(
      title: const Text('Weather Data',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText('Location', data.location, isSubItem: true),
        _buildNullSafeText('Temperature', data.temperature.toStringAsFixed(1),
            unit: '°C', isSubItem: true),
        _buildNullSafeText('Feels Like', data.feelsLike.toStringAsFixed(1),
            unit: '°C', isSubItem: true),
        _buildNullSafeText('Humidity', data.humidity,
            unit: '%', isSubItem: true),
        _buildNullSafeText('Wind Speed', data.windSpeed.toStringAsFixed(1),
            unit: 'm/s', isSubItem: true),
        _buildNullSafeText('Condition', data.condition, isSubItem: true),
      ],
    );
  }

  Widget _buildAirQualityData(AirQualityData data) {
    return ExpansionTile(
      title: const Text('Air Quality (AQI)',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText('Location', data.location, isSubItem: true),
        _buildNullSafeText('AQI', data.aqi, isSubItem: true),
        _buildNullSafeText('AQI Category', data.aqiCategory, isSubItem: true),
        _buildNullSafeText('PM2.5', data.pm25.toStringAsFixed(1),
            unit: 'µg/m³', isSubItem: true),
        _buildNullSafeText('PM10', data.pm10.toStringAsFixed(1),
            unit: 'µg/m³', isSubItem: true),
        _buildNullSafeText('Ozone (O3)', data.o3?.toStringAsFixed(1),
            unit: 'ppb', isSubItem: true),
        _buildNullSafeText(
            'Nitrogen Dioxide (NO2)', data.no2?.toStringAsFixed(1),
            unit: 'ppb', isSubItem: true),
        _buildNullSafeText('Sulfur Dioxide (SO2)', data.so2?.toStringAsFixed(1),
            unit: 'ppb', isSubItem: true),
        _buildNullSafeText('Carbon Monoxide (CO)', data.co?.toStringAsFixed(1),
            unit: 'ppm', isSubItem: true),
      ],
    );
  }

  Widget _buildUVIndexData(UVIndexData data) {
    return ExpansionTile(
      title:
          const Text('UV Index', style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText('Location', data.location, isSubItem: true),
        _buildNullSafeText('UV Index', data.uvIndex.toStringAsFixed(1),
            isSubItem: true),
        _buildNullSafeText('Risk Level', data.riskLevel, isSubItem: true),
        if (data.protectionAdvice != null && data.protectionAdvice!.isNotEmpty)
          _buildDataMap('Protection Advice', data.protectionAdvice!),
      ],
    );
  }

  Widget _buildPollenData(PollenData data) {
    String getCategory(int level) => data.getPollenCategory(level);
    return ExpansionTile(
      title: const Text('Pollen Data',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText('Location', data.location, isSubItem: true),
        _buildNullSafeText('Tree Pollen',
            '${data.treePollenLevel} (${getCategory(data.treePollenLevel)})',
            isSubItem: true),
        _buildNullSafeText('Grass Pollen',
            '${data.grassPollenLevel} (${getCategory(data.grassPollenLevel)})',
            isSubItem: true),
        _buildNullSafeText('Weed Pollen',
            '${data.weedPollenLevel} (${getCategory(data.weedPollenLevel)})',
            isSubItem: true),
        _buildNullSafeText(
            'Mold Level', '${data.moldLevel} (${getCategory(data.moldLevel)})',
            isSubItem: true),
      ],
    );
  }

  Widget _buildSeasonalData(SeasonalData data) {
    return ExpansionTile(
      title: const Text('Seasonal Data',
          style: TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        _buildNullSafeText(
            'Timestamp',
            data.timestamp
                .toLocal()
                .toIso8601String()
                .substring(0, 16)
                .replaceFirst('T', ' '),
            isSubItem: true),
        _buildNullSafeText('Location', data.location, isSubItem: true),
        _buildNullSafeText(
            'Current Season', data.currentSeason.toString().split('.').last,
            isSubItem: true),
        _buildNullSafeText(
            'Allergy Season', data.isAllergySeason ? 'Yes' : 'No',
            isSubItem: true),
        _buildNullSafeText('Flu Season', data.isFluSeason ? 'Yes' : 'No',
            isSubItem: true),
        _buildDataList('Seasonal Advice', data.seasonalAdvice),
      ],
    );
  }
}

// Example usage (typically from a screen that uses a ViewModel):
//
// HealthMetrics sampleMetrics = HealthMetrics( /* ... populate with data ... */ );
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => BodySimulatorView(healthMetrics: sampleMetrics)),
// );
