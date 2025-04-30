import 'package:ate_project/features/debug/debug_view.dart';
import 'package:ate_project/features/home/views/screens/home_view.dart';
import 'package:ate_project/features/onboarding/views/intro_view.dart';
import 'package:ate_project/features/settings/views/screens/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/routes/route_names.dart';

final appRoutes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomeView(),
  ),
  GoRoute(
    path: '/debug',
    builder: (context, state) => const DebugView(),
  ),
  GoRoute(
    path: '/intro',
    builder: (context, state) => const IntroView(),
  ),
  GoRoute(
    path: RouteNames.settings,
    builder: (context, state) => const SettingsView(),
  ),

  // Body simulator route
  GoRoute(
    path: '/body-simulator',
    builder: (context, state) =>
        _buildPlaceholderScreen(context, 'Body Simulator'),
  ),

  // Health logs route
  GoRoute(
    path: '/health-logs',
    builder: (context, state) =>
        _buildPlaceholderScreen(context, 'Health Logs'),
  ),

  // Quick access routes
  GoRoute(
    path: '/activity',
    builder: (context, state) =>
        _buildPlaceholderScreen(context, 'Activity Tracking'),
  ),
  GoRoute(
    path: '/nutrition',
    builder: (context, state) => _buildPlaceholderScreen(context, 'Nutrition'),
  ),
  GoRoute(
    path: '/sleep',
    builder: (context, state) =>
        _buildPlaceholderScreen(context, 'Sleep Tracking'),
  ),
  GoRoute(
    path: '/mood',
    builder: (context, state) =>
        _buildPlaceholderScreen(context, 'Mood Tracking'),
  ),

  // Logging routes
  GoRoute(
    path: '/nutrition/log',
    builder: (context, state) => _buildPlaceholderScreen(context, 'Log Meal'),
  ),
  GoRoute(
    path: '/weight/log',
    builder: (context, state) => _buildPlaceholderScreen(context, 'Log Weight'),
  ),
  GoRoute(
    path: '/symptoms/log',
    builder: (context, state) =>
        _buildPlaceholderScreen(context, 'Log Symptoms'),
  ),
  GoRoute(
    path: '/mood/log',
    builder: (context, state) => _buildPlaceholderScreen(context, 'Log Mood'),
  ),

  // Other routes
  GoRoute(
    path: '/profile',
    builder: (context, state) => _buildPlaceholderScreen(context, 'Profile'),
  ),
  GoRoute(
    path: '/environmental',
    builder: (context, state) =>
        _buildPlaceholderScreen(context, 'Environmental Data'),
  ),
];

// Helper to build placeholder screens
Widget _buildPlaceholderScreen(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '$title',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is coming soon',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
