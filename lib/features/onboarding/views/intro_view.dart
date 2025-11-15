import 'package:flutter/material.dart';
import 'package:bodido/main.dart';

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
            Text($strings.intro_title,
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Text(
              $strings.intro_subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Go to next onboarding step or login
                },
                child: Text($strings.intro_get_started),
              ),
            )
          ],
        ),
      ),
    );
  }
}
