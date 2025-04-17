import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/services/user_service.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/core/services/health_service.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/widgets/auth_prompt_modal.dart';
import 'package:ate_project/data/models/health_model.dart';
import 'dart:io' show Platform;

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasShownAuthPrompt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndShowPrompt();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Check authentication status and show prompt if needed
  Future<void> _checkAuthAndShowPrompt() async {
    if (_hasShownAuthPrompt || !mounted) return;

    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      setState(() {
        _hasShownAuthPrompt = true;
      });

      final shouldLogin = await AuthPromptHelper.showLoginPrompt(
        context,
        title: 'Welcome to the App',
        message:
            'Sign in to access all features and personalize your experience.',
      );

      if (shouldLogin && mounted) {
        await AuthPromptHelper.showLoginActionSheet(
          context,
          onEmailLogin: () {
            if (!mounted) return;
            context.push(RouteNames.login);
          },
          onGoogleLogin: () {
            if (!mounted) return;
            _handleGoogleSignIn();
          },
          onAppleLogin: Platform.isIOS
              ? () {
                  if (!mounted) return;
                  _handleAppleSignIn();
                }
              : null,
        );
      }
    }
  }

  void _handleGoogleSignIn() {
    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.signInWithGoogle();
  }

  void _handleAppleSignIn() {
    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.signInWithApple();
  }

  void _onSendMessage() {
    // In a real implementation, you would handle sending the message here
    _messageController.clear();
  }

  void _onSuggestionTap(HealthSuggestion suggestion) {
    // Handle health suggestions based on category
    switch (suggestion.category) {
      case 'nutrition':
        _messageController.text = "Tell me about food tracking";
        // TODO: Implement nutrition route
        break;
      case 'activity':
        _messageController.text = "Tell me about activity tracking";
        // TODO: Implement activity tracking route
        break;
      case 'environmental':
        _messageController.text = "Tell me about air quality";
        // TODO: Implement environmental data route
        break;
      case 'mood':
        _messageController.text = "Tell me about mood tracking";
        // TODO: Implement mood tracking route
        break;
      case 'profile':
        _messageController.text = "Tell me about health profiles";
        // TODO: Navigate to profile setup
        break;
      default:
        _messageController.text = "Tell me about ${suggestion.label}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    // Get dynamically generated health suggestions
    final healthState = ref.watch(healthProvider);
    final healthSuggestions =
        ref.read(healthProvider.notifier).generateSuggestions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(healthProvider.notifier).loadHealthData(),
            tooltip: 'Refresh health data',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteNames.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Health status overview (optional)
          if (healthState.healthMetrics != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Health data updated',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // Loading indicator
          if (healthState.isLoading) const LinearProgressIndicator(),

          // Error message
          if (healthState.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.red.withOpacity(0.1),
              child: Text(healthState.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Track your health or try a',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'suggestion',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: healthSuggestions
                  .map((suggestion) => GestureDetector(
                        onTap: () => _onSuggestionTap(suggestion),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.7),
                              child: Icon(
                                suggestion.icon,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Input field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Icon
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 16,
                    child: Icon(
                      Icons.health_and_safety,
                      size: 20,
                    ),
                  ),
                ),

                // Text input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    onSubmitted: (_) => _onSendMessage(),
                  ),
                ),

                // Icons on the right
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => context.push(RouteNames.settings),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _onSendMessage,
                ),
              ],
            ),
          ),

          // Beta message
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'BETA',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
