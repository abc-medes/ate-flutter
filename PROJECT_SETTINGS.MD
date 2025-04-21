# Project Settings

## Flutter Version
```bash
Flutter 3.19.0 • channel stable
Dart 3.3.0
```

## Required Commands

### Localization Generation
```bash
flutter gen-l10n
```

**Why is this needed?**
- This command generates the necessary localization files from `.arb` files in ` lib/core/config/l10n/`
- Must be run every time you modify translation strings in `.arb` files
- Generates:
  - `app_localizations.dart`: Base abstract class with all string keys
  - `app_localizations_en.dart`: English translations implementation
  - `app_localizations_ko.dart`: Korean translations implementation
- Provides type-safe access to translations
- Ensures consistency between different language files
- Enables compile-time checking for missing translations
- Generates proper null-safety and documentation for all translation strings 