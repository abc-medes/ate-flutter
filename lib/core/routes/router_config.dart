import 'package:ate_project/features/home/views/screens/home_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for router configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Home screen route
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeView(),
      ),

      // Auth routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen - To be implemented')),
        ),
      ),

      // Body simulator route
      GoRoute(
        path: '/body-simulator',
        builder: (context, state) => const Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56.0),
            child: Material(
              elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SafeArea(
                  child: Row(
                    children: [
                      BackButton(),
                      Text('Body Simulator',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body:
              Center(child: Text('Body Simulator Screen - To be implemented')),
        ),
      ),

      // Health logs route
      GoRoute(
        path: '/health-logs',
        builder: (context, state) => const Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56.0),
            child: Material(
              elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SafeArea(
                  child: Row(
                    children: [
                      BackButton(),
                      Text('Health Logs',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Center(child: Text('Health Logs Screen - To be implemented')),
        ),
      ),

      // Quick access routes
      GoRoute(
        path: '/activity',
        builder: (context, state) =>
            _buildPlaceholderScreen('Activity Tracking'),
      ),
      GoRoute(
        path: '/nutrition',
        builder: (context, state) => _buildPlaceholderScreen('Nutrition'),
      ),
      GoRoute(
        path: '/sleep',
        builder: (context, state) => _buildPlaceholderScreen('Sleep Tracking'),
      ),
      GoRoute(
        path: '/mood',
        builder: (context, state) => _buildPlaceholderScreen('Mood Tracking'),
      ),

      // Logging routes
      GoRoute(
        path: '/nutrition/log',
        builder: (context, state) => _buildPlaceholderScreen('Log Meal'),
      ),
      GoRoute(
        path: '/weight/log',
        builder: (context, state) => _buildPlaceholderScreen('Log Weight'),
      ),
      GoRoute(
        path: '/symptoms/log',
        builder: (context, state) => _buildPlaceholderScreen('Log Symptoms'),
      ),
      GoRoute(
        path: '/mood/log',
        builder: (context, state) => _buildPlaceholderScreen('Log Mood'),
      ),

      // Other routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => _buildPlaceholderScreen('Profile'),
      ),
      GoRoute(
        path: '/environmental',
        builder: (context, state) =>
            _buildPlaceholderScreen('Environmental Data'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
});

// Helper to build placeholder screens
Widget _buildPlaceholderScreen(String title) {
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(56.0),
      child: Material(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SafeArea(
            child: Row(
              children: [
                const BackButton(),
                Text(title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    ),
    body: Center(
      child: Text('$title Screen - To be implemented'),
    ),
  );
}
