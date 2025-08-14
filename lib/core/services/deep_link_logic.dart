import 'package:regene/common_libs.dart';

class DeepLinkLogic {
  WidgetRef? _ref;

  DeepLinkLogic();

  void init(WidgetRef ref) {
    _ref = ref; // Store ref for later use
    final router = ref.read(routerProvider);

    // GoRouter automatically handles deep linking - no need for listeners!
    // The router will automatically respond to deep link URLs
    print('DeepLinkLogic initialized with router: ${router}');
  }

  // Method to programmatically navigate to deep links
  void handleDeepLink(String path, {Map<String, String>? queryParams}) {
    if (_ref == null) return; // Safety check

    final router = _ref!.read(routerProvider);

    switch (path) {
      case '/reset-password':
        final token = queryParams?['access_token'];
        if (token != null) {
          router.go('/reset-password?token=$token');
        }
        break;
      case '/chat':
        router.go('/chat');
        break;
      case '/home':
        router.go('/home');
        break;
      // Add more cases as needed
    }
  }

  void dispose() {
    _ref = null; // Clear ref
  }
}
