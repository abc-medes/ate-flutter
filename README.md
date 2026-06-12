# ATE (bodido) — AI Health Companion

> A Flutter app that turns everyday conversation into a living picture of your
> health, powered by an LLM backend and a real-time body-state model.

ATE lets users talk about their day in plain language — meals, sleep, stress,
symptoms — and reflects it back as an evolving, organ-level "body simulator",
personalized insights, and product recommendations. The app is built with a
feature-first MVVM architecture on Riverpod and GoRouter.

---

## ✨ Features

- **Conversational health logging** — Chat-driven input instead of manual forms.
- **Live body simulator** — A home dashboard that visualizes per-system health
  scores and animates as new state streams in.
- **Personalized insights & tracking questions** — Generated from the user's
  history and surfaced contextually.
- **Guided onboarding** — Multi-step profile capture (body type, conditions,
  allergies, medications, biometrics).
- **Product recommendations** — Tailored suggestions driven by the AI backend.
- **Auth** — Email/password plus Google and Apple sign-in via Supabase.
- **Localization-ready** — `intl`/`flutter_localizations` wiring out of the box.

## 🏗️ Architecture

The codebase follows a **feature-first MVVM** layout: each feature owns its
screens (`views/`) and presentation logic (`view_models/`), while shared
concerns live under `core/` and `data/`.

```
lib/
├── main.dart            # Entry point & dependency bootstrap
├── common_libs.dart     # Barrel of app-wide exports
├── core/                # Cross-cutting infrastructure
│   ├── config/          #   Environment & config (flutter_dotenv)
│   ├── routes/          #   GoRouter navigation
│   ├── services/        #   API client, auth, settings, app services
│   ├── common/          #   Shared helpers (e.g. JSON prefs persistence)
│   ├── utils/           #   Utilities (AppLogger, …)
│   └── widgets/         #   Shared widgets (scaffold, loading overlay, …)
├── data/                # Data layer
│   ├── models/          #   Typed models (health, chat, insights, profiles, …)
│   └── repositories/    #   Repositories over API + local storage
├── features/            # Feature modules (MVVM)
│   ├── auth/            #   Login, signup, password reset
│   ├── onboarding/      #   Multi-step profile capture
│   ├── home/            #   Body-simulator dashboard & insights
│   ├── chat/            #   Conversation UI
│   ├── settings/        #   Profile, AI settings, memorized context
│   └── recommendations/ #   Product recommendations
├── theme/               # Colors, styles, app theme
└── l10n/                # Localization
```

**State management** — Riverpod (`StateNotifier`/providers) keeps view models
testable and rebuilds scoped. **Navigation** — GoRouter centralizes routing.
**DI** — `get_it` wires services and repositories. **Backend** — talks to the
[ATE LangChain backend](../ate-langchain-backend) over REST + WebSocket.

## 🛠️ Tech Stack

| Area              | Choice                                             |
| ----------------- | -------------------------------------------------- |
| Framework         | Flutter (Dart)                                     |
| State management  | Riverpod                                           |
| Navigation        | GoRouter                                           |
| Dependency inj.   | get_it                                             |
| Backend / Auth    | Supabase (+ Google / Apple sign-in)                |
| Networking        | http                                               |
| Local storage     | shared_preferences                                 |
| Analytics         | Firebase Analytics                                 |
| Logging           | `AppLogger` over `dart:developer`                  |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- A configured Supabase project and the ATE backend running

### Setup

```bash
flutter pub get
```

Create a `.env` file in the project root (loaded via `flutter_dotenv`):

```dotenv
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=...
API_BASE_URL=http://localhost:8080
```

### Run

```bash
flutter run            # debug build on a connected device/emulator
flutter analyze        # static analysis (flutter_lints)
```

## 🧭 Conventions

- **Feature-first**: add new functionality as a self-contained module under
  `features/<name>/` with its own `views/` and `view_models/`.
- **Logging**: use `AppLogger.{debug,info,warning,error}` instead of `print`;
  `debug` output is automatically stripped from release builds.
- **Imports**: prefer package imports (`package:bodido/...`).

---

<sub>Built with Flutter, Riverpod, GoRouter, and Supabase.</sub>
