import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  _OnboardingViewState createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  String? selectedCountry;

  void _showCountryPicker() {
    // Example country picker (replace with CupertinoPicker)
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: ["USA", "Korea", "Japan"]
            .map((country) => ListTile(
                  title: Text(country),
                  onTap: () {
                    setState(() {
                      selectedCountry = country;
                    });
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authStateProvider.notifier);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Onboarding")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showCountryPicker,
              child: Text(selectedCountry ?? "Select Country"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedCountry == null
                  ? null // Disable button until a country is selected
                  : () {
                      authNotifier
                          .completeOnboarding(); // ✅ Update global state
                      context.go('/home'); // ✅ Navigate to Home
                    },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
