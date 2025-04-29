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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
});
