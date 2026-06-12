import 'package:bodido/data/models/profiles/_app_open_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenState', () {
    test('has sensible defaults', () {
      const state = OpenState();
      expect(state.isAppOpen, isFalse);
      expect(state.hasOpened, isFalse);
      expect(state.lastOpenedAt, isNull);
      expect(state.lastClosedAt, isNull);
    });

    test('fromJson parses flags and ISO timestamps', () {
      final state = OpenState.fromJson({
        'is_app_open': true,
        'has_opened_app': true,
        'last_opened_at': '2026-01-02T03:04:05.000Z',
        'last_closed_at': null,
      });
      expect(state.isAppOpen, isTrue);
      expect(state.hasOpened, isTrue);
      expect(state.lastOpenedAt, DateTime.parse('2026-01-02T03:04:05.000Z'));
      expect(state.lastClosedAt, isNull);
    });

    test('toJson serializes timestamps to ISO-8601 strings', () {
      final opened = DateTime.parse('2026-01-02T03:04:05.000Z');
      final state = OpenState(isAppOpen: true, hasOpened: true, lastOpenedAt: opened);
      final json = state.toJson();
      expect(json['is_app_open'], isTrue);
      expect(json['has_opened_app'], isTrue);
      expect(json['last_opened_at'], opened.toIso8601String());
      expect(json['last_closed_at'], isNull);
    });

    test('round-trips through fromJson/toJson', () {
      final original = OpenState(
        isAppOpen: true,
        hasOpened: true,
        lastOpenedAt: DateTime.parse('2026-01-02T03:04:05.000Z'),
        lastClosedAt: DateTime.parse('2026-01-02T09:10:11.000Z'),
      );
      final restored = OpenState.fromJson(original.toJson());
      expect(restored.isAppOpen, original.isAppOpen);
      expect(restored.hasOpened, original.hasOpened);
      expect(restored.lastOpenedAt, original.lastOpenedAt);
      expect(restored.lastClosedAt, original.lastClosedAt);
    });

    test('copyWith overrides only provided fields', () {
      const base = OpenState(isAppOpen: false, hasOpened: false);
      final updated = base.copyWith(isAppOpen: true);
      expect(updated.isAppOpen, isTrue);
      expect(updated.hasOpened, isFalse);
    });
  });
}
