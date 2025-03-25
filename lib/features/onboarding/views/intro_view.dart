import 'package:flutter/material.dart';

class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AI Meal Planner",
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Text(
              "Track, analyze, and optimize your nutrition using AI. Smart meals, smarter habits.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Go to next onboarding step or login
                },
                child: const Text("Get Started"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
