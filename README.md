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

📂 Folder Structure

This project follows the MVVM (Model-View-ViewModel) architecture with Riverpod.

ate_project/
│── lib/
│ ├── core/ # Core utilities and global services
│ │ ├── routes/ # App routing (GoRouter)
│ │ │ ├── router_provider.dart # Manages routing logic
│ │ │ ├── auth_routes.dart # Authentication-related routes
│ │ │ ├── app_routes.dart # Main app routes
│ │ ├── services/ # Business logic and API services
│ │ │ ├── auth_service.dart # Authentication state management
│ │ │ ├── current_app_theme_service.dart # Dark/Light mode service
│ ├── features/ # Application features/modules
│ │ ├── auth/ # Authentication module (Login, Register, Onboarding)
│ │ │ ├── views/ # UI screens related to authentication
│ │ │ ├── state/ # Riverpod state management for auth
│ │ ├── app/ # Main app module
│ │ │ ├── views/ # UI screens for home, dashboard, etc.
│ │ │ ├── state/ # ViewModels and state management for app
│ ├── presentation/ # UI Layer (Organized per feature)
│ │ ├── widgets/ # Reusable UI components (buttons, forms)
│ │ ├── theme/ # Global app theme & styles
│ ├── main.dart # Application entry point
│── README.md # Project documentation
