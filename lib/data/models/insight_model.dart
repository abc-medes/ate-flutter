import 'package:flutter/material.dart';

class InsightItem {
  final String title;
  final String value;
  final String advice;
  final String icon;
  final int priority;

  InsightItem({
    required this.title,
    required this.value,
    required this.advice,
    required this.icon,
    required this.priority,
  });

  factory InsightItem.fromJson(Map<String, dynamic> json) {
    return InsightItem(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      advice: json['advice'] ?? '',
      icon: json['icon'] ?? 'info',
      priority: json['priority'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'advice': advice,
      'icon': icon,
      'priority': priority,
    };
  }

  IconData get iconData {
    switch (icon) {
      case 'local_fire_department_outlined':
        return Icons.local_fire_department_outlined;
      case 'sentiment_very_dissatisfied_outlined':
        return Icons.sentiment_very_dissatisfied_outlined;
      case 'directions_run_outlined':
        return Icons.directions_run_outlined;
      case 'shield_outlined':
        return Icons.shield_outlined;
      case 'nightlight_round_outlined':
        return Icons.nightlight_round_outlined;
      case 'psychology_outlined':
        return Icons.psychology_outlined;
      case 'favorite_outlined':
        return Icons.favorite_outlined;
      case 'water_drop_outlined':
        return Icons.water_drop_outlined;
      case 'restaurant_outlined':
        return Icons.restaurant_outlined;
      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

class InsightsRecord {
  final String id;
  final String userId;
  final List<InsightItem> insights;
  final Map<String, dynamic> bodyStateSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  InsightsRecord({
    required this.id,
    required this.userId,
    required this.insights,
    required this.bodyStateSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InsightsRecord.fromJson(Map<String, dynamic> json) {
    return InsightsRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      insights: (json['insights'] as List<dynamic>?)
              ?.map((item) => InsightItem.fromJson(item))
              .toList() ??
          [],
      bodyStateSnapshot: json['body_state_snapshot'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'insights': insights.map((item) => item.toJson()).toList(),
      'body_state_snapshot': bodyStateSnapshot,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
