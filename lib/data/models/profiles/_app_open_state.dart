class OpenState {
  final bool isAppOpen; // `true` while app is in foreground
  final bool hasOpened; // `true` after the very first launch
  final DateTime? lastOpenedAt; // local-device timestamp
  final DateTime? lastClosedAt; // local-device timestamp

  const OpenState({
    this.isAppOpen = false,
    this.hasOpened = false,
    this.lastOpenedAt,
    this.lastClosedAt,
  });

  /* ───────────────── factory / JSON ───────────────── */

  factory OpenState.fromJson(Map<String, dynamic> json) => OpenState(
        isAppOpen: json['is_app_open'] ?? false,
        hasOpened: json['has_opened_app'] ?? false,
        lastOpenedAt: json['last_opened_at'] != null
            ? DateTime.parse(json['last_opened_at'])
            : null,
        lastClosedAt: json['last_closed_at'] != null
            ? DateTime.parse(json['last_closed_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'is_app_open': isAppOpen,
        'has_opened_app': hasOpened,
        'last_opened_at': lastOpenedAt?.toIso8601String(),
        'last_closed_at': lastClosedAt?.toIso8601String(),
      };

  /* ───────────────── copyWith helper ───────────────── */

  OpenState copyWith({
    bool? isAppOpen,
    bool? hasOpened,
    DateTime? lastOpenedAt,
    DateTime? lastClosedAt,
  }) =>
      OpenState(
        isAppOpen: isAppOpen ?? this.isAppOpen,
        hasOpened: hasOpened ?? this.hasOpened,
        lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
        lastClosedAt: lastClosedAt ?? this.lastClosedAt,
      );
}
