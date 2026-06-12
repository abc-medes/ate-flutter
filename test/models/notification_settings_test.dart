import 'package:bodido/data/models/profiles/_notification_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationSettings', () {
    test('defaults to enabled', () {
      final settings = NotificationSettings();
      expect(settings.pushEnabled, isTrue);
      expect(settings.emailEnabled, isTrue);
    });

    test('fromJson reads snake_case keys', () {
      final settings = NotificationSettings.fromJson({
        'push_enabled': false,
        'email_enabled': true,
      });
      expect(settings.pushEnabled, isFalse);
      expect(settings.emailEnabled, isTrue);
    });

    test('fromJson falls back to defaults for missing keys', () {
      final settings = NotificationSettings.fromJson({});
      expect(settings.pushEnabled, isTrue);
      expect(settings.emailEnabled, isTrue);
    });

    test('toJson round-trips through fromJson', () {
      final original = NotificationSettings(pushEnabled: false, emailEnabled: true);
      final restored = NotificationSettings.fromJson(original.toJson());
      expect(restored.pushEnabled, original.pushEnabled);
      expect(restored.emailEnabled, original.emailEnabled);
    });

    test('copyWith overrides only the provided fields', () {
      final base = NotificationSettings(pushEnabled: true, emailEnabled: true);
      final updated = base.copyWith(pushEnabled: false);
      expect(updated.pushEnabled, isFalse);
      expect(updated.emailEnabled, isTrue);
    });
  });
}
