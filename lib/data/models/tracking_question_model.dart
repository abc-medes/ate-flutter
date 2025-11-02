// lib/data/models/tracking_question_model.dart

double _parseDouble(dynamic v) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

enum ValueType { band, range }

ValueType _valueTypeFromString(String? v) {
  switch (v) {
    case 'band':
      return ValueType.band;
    case 'range':
      return ValueType.range;
    default:
      return ValueType.band;
  }
}

String _valueTypeToString(ValueType v) {
  switch (v) {
    case ValueType.band:
      return 'band';
    case ValueType.range:
      return 'range';
  }
}

enum BodySystem {
  Brain,
  Heart,
  Lungs,
  Liver,
  Stomach,
  Intestines,
  Kidneys,
  Endocrine,
  Nervous,
}

BodySystem _bodySystemFromString(String? v) {
  switch (v) {
    case 'Brain':
      return BodySystem.Brain;
    case 'Heart':
      return BodySystem.Heart;
    case 'Lungs':
      return BodySystem.Lungs;
    case 'Liver':
      return BodySystem.Liver;
    case 'Stomach':
      return BodySystem.Stomach;
    case 'Intestines':
      return BodySystem.Intestines;
    case 'Kidneys':
      return BodySystem.Kidneys;
    case 'Endocrine':
      return BodySystem.Endocrine;
    case 'Nervous':
      return BodySystem.Nervous;
    default:
      return BodySystem.Brain;
  }
}

String _bodySystemToString(BodySystem v) {
  switch (v) {
    case BodySystem.Brain:
      return 'Brain';
    case BodySystem.Heart:
      return 'Heart';
    case BodySystem.Lungs:
      return 'Lungs';
    case BodySystem.Liver:
      return 'Liver';
    case BodySystem.Stomach:
      return 'Stomach';
    case BodySystem.Intestines:
      return 'Intestines';
    case BodySystem.Kidneys:
      return 'Kidneys';
    case BodySystem.Endocrine:
      return 'Endocrine';
    case BodySystem.Nervous:
      return 'Nervous';
  }
}

class DataCapture {
  final String type; // only "trend" for now
  final String metric;
  final ValueType valueType; // "band" | "range"
  final String valueLabel;
  final String unit;
  final double? normalizedValue;

  DataCapture({
    required this.type,
    required this.metric,
    required this.valueType,
    required this.valueLabel,
    required this.unit,
    this.normalizedValue,
  });

  factory DataCapture.fromJson(Map<String, dynamic> json) {
    return DataCapture(
      type: json['type']?.toString() ?? 'trend',
      metric: json['metric']?.toString() ?? '',
      valueType: _valueTypeFromString(json['value_type']?.toString()),
      valueLabel: json['value_label']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      normalizedValue: json['normalized_value'] == null
          ? null
          : _parseDouble(json['normalized_value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'metric': metric,
      'value_type': _valueTypeToString(valueType),
      'value_label': valueLabel,
      'unit': unit,
      if (normalizedValue != null) 'normalized_value': normalizedValue,
    };
  }
}

class QuestionOption {
  final String id;
  final String label;
  final String selectionKey;
  final List<String>? effectTags;
  final String instantFeedback;
  final DataCapture? dataCapture;

  QuestionOption({
    required this.id,
    required this.label,
    required this.selectionKey,
    this.effectTags,
    required this.instantFeedback,
    this.dataCapture,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      selectionKey: json['selection_key']?.toString() ?? '',
      effectTags:
          (json['effect_tags'] as List?)?.map((e) => e.toString()).toList(),
      instantFeedback: json['instant_feedback']?.toString() ?? '',
      dataCapture: json['data_capture'] is Map<String, dynamic>
          ? DataCapture.fromJson(json['data_capture'])
          : (json['data_capture'] == null
              ? null
              : DataCapture.fromJson(
                  Map<String, dynamic>.from(json['data_capture']))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'selection_key': selectionKey,
      if (effectTags != null) 'effect_tags': effectTags,
      'instant_feedback': instantFeedback,
      if (dataCapture != null) 'data_capture': dataCapture!.toJson(),
    };
  }
}

class TrackingQuestion {
  final String id;
  final String category; // always "TRACKING"
  final BodySystem system;
  final String metric; // e.g., "weight_kg"
  final String questionTag; // default "general"
  final double priority;
  final String question;
  final String? rationale;
  final List<QuestionOption> options;

  TrackingQuestion({
    required this.id,
    this.category = 'TRACKING',
    required this.system,
    required this.metric,
    this.questionTag = 'general',
    this.priority = 0.0,
    required this.question,
    this.rationale,
    required this.options,
  });

  factory TrackingQuestion.fromJson(Map<String, dynamic> json) {
    return TrackingQuestion(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'TRACKING',
      system: _bodySystemFromString(json['system']?.toString()),
      metric: json['metric']?.toString() ?? '',
      questionTag: json['question_tag']?.toString() ?? 'general',
      priority: _parseDouble(json['priority']),
      question: json['question']?.toString() ?? '',
      rationale: json['rationale']?.toString(),
      options: (json['options'] as List? ?? const [])
          .map((e) => e is Map<String, dynamic>
              ? QuestionOption.fromJson(e)
              : QuestionOption.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'system': _bodySystemToString(system),
      'metric': metric,
      'question_tag': questionTag,
      'priority': priority,
      'question': question,
      if (rationale != null) 'rationale': rationale,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class TrackingQuestionBatch {
  final List<TrackingQuestion> questions;
  final String language;

  TrackingQuestionBatch({
    required this.questions,
    required this.language,
  });

  factory TrackingQuestionBatch.fromJson(Map<String, dynamic> json) {
    return TrackingQuestionBatch(
      questions: (json['questions'] as List? ?? const [])
          .map((e) => e is Map<String, dynamic>
              ? TrackingQuestion.fromJson(e)
              : TrackingQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      language: json['language']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((e) => e.toJson()).toList(),
      'language': language,
    };
  }
}

// Add near your other enums
enum BindingStatus { pending, selected, dismissed }

BindingStatus _bindingStatusFromString(String? v) {
  switch (v) {
    case 'selected':
      return BindingStatus.selected;
    case 'dismissed':
      return BindingStatus.dismissed;
    case 'pending':
    default:
      return BindingStatus.pending;
  }
}

String _bindingStatusToString(BindingStatus v) {
  switch (v) {
    case BindingStatus.selected:
      return 'selected';
    case BindingStatus.dismissed:
      return 'dismissed';
    case BindingStatus.pending:
      return 'pending';
  }
}

class UserQuestionBinding {
  final String userId;
  final String? sessionId;
  final String questionId;
  final String questionTag;
  final BodySystem? system;
  final String? metric;
  final double? priority; // default 0.0 if not supplied
  final String? optionId;
  final String? selectionKey;
  final Map<String, dynamic>? dataCapture;
  final DateTime? clientLocalTimestamp;
  final BindingStatus status; // "pending" | "selected" | "dismissed"
  final DateTime? generatedForBodyStateAt;

  UserQuestionBinding({
    required this.userId,
    this.sessionId,
    required this.questionId,
    required this.questionTag,
    this.system,
    this.metric,
    this.priority = 0.0,
    this.optionId,
    this.selectionKey,
    this.dataCapture,
    this.clientLocalTimestamp,
    this.status = BindingStatus.pending,
    this.generatedForBodyStateAt,
  });

  factory UserQuestionBinding.fromJson(Map<String, dynamic> json) {
    return UserQuestionBinding(
      userId: json['user_id']?.toString() ?? '',
      sessionId: json['session_id']?.toString(),
      questionId: json['question_id']?.toString() ?? '',
      questionTag: json['question_tag']?.toString() ?? '',
      system: json['system'] != null
          ? _bodySystemFromString(json['system']?.toString())
          : null,
      metric: json['metric']?.toString(),
      priority: json['priority'] == null ? 0.0 : _parseDouble(json['priority']),
      optionId: json['option_id']?.toString(),
      selectionKey: json['selection_key']?.toString(),
      dataCapture: json['data_capture'] is Map<String, dynamic>
          ? json['data_capture']
          : (json['data_capture'] == null
              ? null
              : Map<String, dynamic>.from(json['data_capture'])),
      clientLocalTimestamp: json['client_local_timestamp_iso'] != null
          ? DateTime.tryParse(json['client_local_timestamp_iso'].toString())
          : null,
      status: _bindingStatusFromString(json['status']?.toString()),
      generatedForBodyStateAt: json['generated_for_body_state_at'] != null
          ? DateTime.tryParse(json['generated_for_body_state_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      'question_id': questionId,
      'question_tag': questionTag,
      if (system != null) 'system': _bodySystemToString(system!),
      if (metric != null) 'metric': metric,
      if (priority != null) 'priority': priority,
      if (optionId != null) 'option_id': optionId,
      if (selectionKey != null) 'selection_key': selectionKey,
      if (dataCapture != null) 'data_capture': dataCapture,
      if (clientLocalTimestamp != null)
        'client_local_timestamp_iso': clientLocalTimestamp!.toIso8601String(),
      'status': _bindingStatusToString(status),
      if (generatedForBodyStateAt != null)
        'generated_for_body_state_at':
            generatedForBodyStateAt!.toIso8601String(),
    };
  }
}

// Request for selecting an option
class UserSelectionRequest {
  final String questionId;
  final String questionTag;
  final String optionId;
  final String selectionKey;
  final String? sessionId;
  final DateTime? clientLocalTimestamp;

  UserSelectionRequest({
    required this.questionId,
    required this.questionTag,
    required this.optionId,
    required this.selectionKey,
    this.sessionId,
    this.clientLocalTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_tag': questionTag,
      'option_id': optionId,
      'selection_key': selectionKey,
      if (sessionId != null) 'session_id': sessionId,
      if (clientLocalTimestamp != null)
        'client_local_timestamp_iso': clientLocalTimestamp!.toIso8601String(),
    };
  }
}
