// body_simulator_model.dart

// Helper to safely parse doubles from JSON, handling int or double types

double _parseDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0; // Default or throw error
}

class BrainData {
  final double stressLevel;
  final double serotonin;
  final double sleepRhythm;
  final double cortisol;

  BrainData({
    required this.stressLevel,
    required this.serotonin,
    required this.sleepRhythm,
    required this.cortisol,
  });

  factory BrainData.fromJson(Map<String, dynamic> json) {
    return BrainData(
      stressLevel: _parseDouble(json['stressLevel']),
      serotonin: _parseDouble(json['serotonin']),
      sleepRhythm: _parseDouble(json['sleepRhythm']),
      cortisol: _parseDouble(json['cortisol']),
    );
  }

  Map<String, dynamic> toJson() => {
        'stressLevel': stressLevel,
        'serotonin': serotonin,
        'sleepRhythm': sleepRhythm,
        'cortisol': cortisol,
      };
}

class HeartData {
  final double bloodSugar;
  final double bloodPressure;
  final double heartRate;
  final double hrv; // HRV

  HeartData({
    required this.bloodSugar,
    required this.bloodPressure,
    required this.heartRate,
    required this.hrv,
  });

  factory HeartData.fromJson(Map<String, dynamic> json) {
    return HeartData(
      bloodSugar: _parseDouble(json['bloodSugar']),
      bloodPressure: _parseDouble(json['bloodPressure']),
      heartRate: _parseDouble(json['heartRate']),
      hrv: _parseDouble(json['HRV']),
    );
  }

  Map<String, dynamic> toJson() => {
        'bloodSugar': bloodSugar,
        'bloodPressure': bloodPressure,
        'heartRate': heartRate,
        'HRV': hrv,
      };
}

class LungsData {
  final double oxygenSaturation;
  final double lungHealth;
  final double pmExposure;
  final double respiratoryRate;

  LungsData({
    required this.oxygenSaturation,
    required this.lungHealth,
    required this.pmExposure,
    required this.respiratoryRate,
  });

  factory LungsData.fromJson(Map<String, dynamic> json) {
    return LungsData(
      oxygenSaturation: _parseDouble(json['oxygenSaturation']),
      lungHealth: _parseDouble(json['lungHealth']),
      pmExposure: _parseDouble(json['pmExposure']),
      respiratoryRate: _parseDouble(json['respiratoryRate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'oxygenSaturation': oxygenSaturation,
        'lungHealth': lungHealth,
        'pmExposure': pmExposure,
        'respiratoryRate': respiratoryRate,
      };
}

class LiverData {
  final double detoxCapacity;
  final double liverEnzymes;
  final double fatProcessing;
  final double alcoholLoad;

  LiverData({
    required this.detoxCapacity,
    required this.liverEnzymes,
    required this.fatProcessing,
    required this.alcoholLoad,
  });

  factory LiverData.fromJson(Map<String, dynamic> json) {
    return LiverData(
      detoxCapacity: _parseDouble(json['detoxCapacity']),
      liverEnzymes: _parseDouble(json['liverEnzymes']),
      fatProcessing: _parseDouble(json['fatProcessing']),
      alcoholLoad: _parseDouble(json['alcoholLoad']),
    );
  }

  Map<String, dynamic> toJson() => {
        'detoxCapacity': detoxCapacity,
        'liverEnzymes': liverEnzymes,
        'fatProcessing': fatProcessing,
        'alcoholLoad': alcoholLoad,
      };
}

class StomachData {
  final double digestionSpeed;
  final double acidity;
  final double nauseaRisk;
  final double foodRetention;

  StomachData({
    required this.digestionSpeed,
    required this.acidity,
    required this.nauseaRisk,
    required this.foodRetention,
  });

  factory StomachData.fromJson(Map<String, dynamic> json) {
    return StomachData(
      digestionSpeed: _parseDouble(json['digestionSpeed']),
      acidity: _parseDouble(json['acidity']),
      nauseaRisk: _parseDouble(json['nauseaRisk']),
      foodRetention: _parseDouble(json['foodRetention']),
    );
  }

  Map<String, dynamic> toJson() => {
        'digestionSpeed': digestionSpeed,
        'acidity': acidity,
        'nauseaRisk': nauseaRisk,
        'foodRetention': foodRetention,
      };
}

class IntestinesData {
  final double gutBacteriaDiversity;
  final double inflammation;
  final double absorptionRate;
  final double gasLevel;

  IntestinesData({
    required this.gutBacteriaDiversity,
    required this.inflammation,
    required this.absorptionRate,
    required this.gasLevel,
  });

  factory IntestinesData.fromJson(Map<String, dynamic> json) {
    return IntestinesData(
      gutBacteriaDiversity: _parseDouble(json['gutBacteriaDiversity']),
      inflammation: _parseDouble(json['inflammation']),
      absorptionRate: _parseDouble(json['absorptionRate']),
      gasLevel: _parseDouble(json['gasLevel']),
    );
  }

  Map<String, dynamic> toJson() => {
        'gutBacteriaDiversity': gutBacteriaDiversity,
        'inflammation': inflammation,
        'absorptionRate': absorptionRate,
        'gasLevel': gasLevel,
      };
}

class KidneysData {
  final double hydration;
  final double electrolyteBalance;
  final double ureaClearance;
  final double toxicityLoad;

  KidneysData({
    required this.hydration,
    required this.electrolyteBalance,
    required this.ureaClearance,
    required this.toxicityLoad,
  });

  factory KidneysData.fromJson(Map<String, dynamic> json) {
    return KidneysData(
      hydration: _parseDouble(json['hydration']),
      electrolyteBalance: _parseDouble(json['electrolyteBalance']),
      ureaClearance: _parseDouble(json['ureaClearance']),
      toxicityLoad: _parseDouble(json['toxicityLoad']),
    );
  }

  Map<String, dynamic> toJson() => {
        'hydration': hydration,
        'electrolyteBalance': electrolyteBalance,
        'ureaClearance': ureaClearance,
        'toxicityLoad': toxicityLoad,
      };
}

class EndocrineData {
  final double insulinSensitivity;
  final double thyroidFunction;
  final double estrogenTestosteroneRatio;

  EndocrineData({
    required this.insulinSensitivity,
    required this.thyroidFunction,
    required this.estrogenTestosteroneRatio,
  });

  factory EndocrineData.fromJson(Map<String, dynamic> json) {
    return EndocrineData(
      insulinSensitivity: _parseDouble(json['insulinSensitivity']),
      thyroidFunction: _parseDouble(json['thyroidFunction']),
      estrogenTestosteroneRatio:
          _parseDouble(json['estrogenTestosteroneRatio']),
    );
  }

  Map<String, dynamic> toJson() => {
        'insulinSensitivity': insulinSensitivity,
        'thyroidFunction': thyroidFunction,
        'estrogenTestosteroneRatio': estrogenTestosteroneRatio,
      };
}

class NervousData {
  final double focusLevel;
  final double moodStability;
  final double anxietyLevel;
  final double neuroFlexibility;

  NervousData({
    required this.focusLevel,
    required this.moodStability,
    required this.anxietyLevel,
    required this.neuroFlexibility,
  });

  factory NervousData.fromJson(Map<String, dynamic> json) {
    return NervousData(
      focusLevel: _parseDouble(json['focusLevel']),
      moodStability: _parseDouble(json['moodStability']),
      anxietyLevel: _parseDouble(json['anxietyLevel']),
      neuroFlexibility: _parseDouble(json['neuroFlexibility']),
    );
  }

  Map<String, dynamic> toJson() => {
        'focusLevel': focusLevel,
        'moodStability': moodStability,
        'anxietyLevel': anxietyLevel,
        'neuroFlexibility': neuroFlexibility,
      };
}

class BodyOverallScore {
  final double overallScore;
  final Map<String, double> organScores;
  final String? diagnosisText;
  final List<HealthAnalysisItem> strengths;
  final List<HealthAnalysisItem> concerns;
  final List<HealthAnalysisItem> allAnalyses;

  BodyOverallScore({
    required this.overallScore,
    required this.organScores,
    this.diagnosisText,
    this.strengths = const [],
    this.concerns = const [],
    this.allAnalyses = const [],
  });

  factory BodyOverallScore.fromJson(Map<String, dynamic> json) {
    final organScoresRaw = json['organ_scores'] ?? json['health_score'];
    final Map<String, double> organScoresParsed = organScoresRaw is Map
        ? organScoresRaw.map<String, double>(
            (k, v) => MapEntry(k.toString(), _parseDouble(v)))
        : <String, double>{};

    List<HealthAnalysisItem> _parseItems(dynamic arr) {
      if (arr is List) {
        return arr
            .map((e) => e is Map<String, dynamic>
                ? HealthAnalysisItem.fromJson(e)
                : HealthAnalysisItem.fromJson(
                    Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return const [];
    }

    return BodyOverallScore(
      overallScore: _parseDouble(json['overall_score']),
      organScores: organScoresParsed,
      diagnosisText: json['diagnosis_text'] as String?,
      strengths: _parseItems(json['strengths']),
      concerns: _parseItems(json['concerns']),
      allAnalyses: _parseItems(json['all_analyses']),
    );
  }

  Map<String, dynamic> toJson() => {
        'overall_score': overallScore,
        'organ_scores': organScores,
        if (diagnosisText != null) 'diagnosis_text': diagnosisText,
        'strengths': strengths.map((e) => e.toJson()).toList(),
        'concerns': concerns.map((e) => e.toJson()).toList(),
        'all_analyses': allAnalyses.map((e) => e.toJson()).toList(),
      };

  factory BodyOverallScore.empty() {
    return BodyOverallScore(
      overallScore: 0.0,
      organScores: {},
    );
  }
}

class HealthAnalysisItem {
  final String organ;
  final double score;
  final String rating;
  final String summary;
  final List<String> keyMetrics;

  HealthAnalysisItem({
    required this.organ,
    required this.score,
    required this.rating,
    required this.summary,
    required this.keyMetrics,
  });

  factory HealthAnalysisItem.fromJson(Map<String, dynamic> json) {
    return HealthAnalysisItem(
      organ: json['organ']?.toString() ?? '',
      score: _parseDouble(json['score']),
      rating: json['rating']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      keyMetrics:
          (json['key_metrics'] as List?)?.map((e) => e.toString()).toList() ??
              <String>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'organ': organ,
        'score': score,
        'rating': rating,
        'summary': summary,
        'key_metrics': keyMetrics,
      };
}

// Next, the class to hold the state (all organs)
class BodySimulatorState {
  final BrainData? brain;
  final HeartData? heart;
  final LungsData? lungs;
  final LiverData? liver;
  final StomachData? stomach;
  final IntestinesData? intestines;
  final KidneysData? kidneys;
  final EndocrineData? endocrine;
  final NervousData? nervous;

  BodySimulatorState({
    this.brain,
    this.heart,
    this.lungs,
    this.liver,
    this.stomach,
    this.intestines,
    this.kidneys,
    this.endocrine,
    this.nervous,
  });

  factory BodySimulatorState.fromJson(Map<String, dynamic> json) {
    return BodySimulatorState(
      brain: json['Brain'] != null ? BrainData.fromJson(json['Brain']) : null,
      heart: json['Heart'] != null ? HeartData.fromJson(json['Heart']) : null,
      lungs: json['Lungs'] != null ? LungsData.fromJson(json['Lungs']) : null,
      liver: json['Liver'] != null ? LiverData.fromJson(json['Liver']) : null,
      stomach: json['Stomach'] != null
          ? StomachData.fromJson(json['Stomach'])
          : null,
      intestines: json['Intestines'] != null
          ? IntestinesData.fromJson(json['Intestines'])
          : null,
      kidneys: json['Kidneys'] != null
          ? KidneysData.fromJson(json['Kidneys'])
          : null,
      endocrine: json['Endocrine'] != null
          ? EndocrineData.fromJson(json['Endocrine'])
          : null,
      nervous: json['Nervous'] != null
          ? NervousData.fromJson(json['Nervous'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (brain != null) data['Brain'] = brain!.toJson();
    if (heart != null) data['Heart'] = heart!.toJson();
    if (lungs != null) data['Lungs'] = lungs!.toJson();
    if (liver != null) data['Liver'] = liver!.toJson();
    if (stomach != null) data['Stomach'] = stomach!.toJson();
    if (intestines != null) data['Intestines'] = intestines!.toJson();
    if (kidneys != null) data['Kidneys'] = kidneys!.toJson();
    if (endocrine != null) data['Endocrine'] = endocrine!.toJson();
    if (nervous != null) data['Nervous'] = nervous!.toJson();
    return data;
  }

  // Factory for an empty state, useful for initialization
  factory BodySimulatorState.empty() {
    return BodySimulatorState(); // All fields will be null
  }
}

class BodySimulatorStateSnapshotDTO {
  final int id;
  final String userId;
  final String sessionId;
  final BodySimulatorState bodyState;
  final BodyOverallScore healthScore;
  final DateTime lastUpdatedAt;
  final DateTime lastUpdatedAtUtc;
  final DateTime createdAt;

  BodySimulatorStateSnapshotDTO({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.bodyState,
    required this.healthScore,
    required this.lastUpdatedAt,
    required this.lastUpdatedAtUtc,
    required this.createdAt,
  });

  factory BodySimulatorStateSnapshotDTO.fromJson(Map<String, dynamic> json) {
    return BodySimulatorStateSnapshotDTO(
      id: (json['id'] ?? 0) as int,
      userId: json['user_id'],
      sessionId: json['session_id'],
      bodyState: BodySimulatorState.fromJson(json['body_state']),
      healthScore: BodyOverallScore.fromJson(json['health_score']),
      lastUpdatedAt: DateTime.parse(json['last_updated_at']),
      lastUpdatedAtUtc: DateTime.parse(json['last_updated_at_utc']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'session_id': sessionId,
        'body_state': bodyState.toJson(),
        'health_score': healthScore.toJson(),
        'last_updated_at': lastUpdatedAt.toIso8601String(),
        'last_updated_at_utc': lastUpdatedAtUtc.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
