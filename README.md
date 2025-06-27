📌 ATE Project

A Flutter project following a structured architecture using Riverpod and GoRouter.

🚀 Getting Started

This project is built with:
• Flutter
• Riverpod (State Management)
• GoRouter (Navigation)
• SharedPreferences (Local Storage)

For a complete guide, check out:
• Flutter Docs
• Riverpod
• GoRouter

---

📌 Updated Folder Structure (MVVM with features/)

This new structure keeps things modular and follows feature-based organization instead of separating purely by MVC layers.

lib/
│── core/ # Core utilities and global services
│ ├── services/ # Global services (e.g., authentication, theme)
│ ├── utils/ # Helper functions, extensions, validators
│ ├── constants/ # App-wide constants, themes, colors
│ ├── routes/ # Navigation (GoRouter)
│ │ ├── router_provider.dart # Centralized routing
│ │ ├── auth_routes.dart # Authentication routes
│ │ ├── app_routes.dart # Main application routes
│── data/ # Data sources (API, Local Storage, Repositories)
│ ├── models/ # Data models (JSON serialization)
│ ├── repositories/ # Repository pattern for API and DB
│ ├── sources/ # Data sources (API, Local Storage)
│── domain/ # Business logic layer
│ ├── entities/ # Core domain entities
│ ├── usecases/ # Business logic & reusable features
│── features/ # **Feature-based Organization**
│ ├── auth/ # Authentication feature
│ │ ├── views/ # Screens related to authentication
│ │ ├── state/ # Riverpod state management for auth
│ ├── home/ # Home feature
│ │ ├── views/ # Home screen UI
│ │ ├── state/ # Riverpod state management for home
│ ├── settings/ # Settings feature
│ │ ├── views/ # Settings UI
│ │ ├── state/ # State management for settings
│── presentation/ # **UI Layer (Organized per feature)**
│ ├── widgets/ # **Reusable UI components (buttons, forms)**
│ ├── theme/ # **Global app theme & styles**
│── main.dart # Application entry point

---

📌 Design Pattern & Architecture

We follow MVVM with Riverpod for clean state management and GoRouter for structured navigation.

1️⃣ Core Layer (lib/core/)

✅ services/ → Handles business logic, API calls, and app-wide services (e.g., authentication, theme).
✅ routes/ → Manages navigation using GoRouter, including router_provider.dart.

---

2️⃣ Feature Layer (lib/features/)

Each feature (Auth, App, Profile, etc.) is structured as:

```
features/
│── auth/
│   ├── views/  # Screens (LoginView, OnboardingView)
│   ├── state/  # Riverpod providers & state management
│── app/
│   ├── views/  # Screens (HomeView, DashboardView)
│   ├── state/  # Riverpod state management
```

✅ Separation of Concerns → Each feature has its own UI (views/) and state (state/).
✅ Scalable → New features can be added without affecting other modules.

---

3️⃣ Presentation Layer (lib/presentation/)

Contains reusable UI components and global themes.

✅ widgets/ → Common UI elements (buttons, forms).
✅ theme/ → Stores global styles and dark/light mode configuration.

---

Riverpod State Management

We use Riverpod’s StateNotifier for handling complex states efficiently.

This ensures:
• No unnecessary rebuilds
• Predictable & testable state management


TODO: signup 로직 확인