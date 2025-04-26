import 'package:ate_project/features/home/views/widgets/action_item.dart';
import 'package:ate_project/features/home/views/widgets/insight_card.dart';
import 'package:ate_project/features/home/views/widgets/login_prompt_card.dart';
import 'package:ate_project/features/home/views/widgets/navigation_card.dart';
import 'package:ate_project/features/home/views/widgets/quick_access_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/data/repositories/health_repository.dart';
import 'package:ate_project/data/models/health_model.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late bool _showLoginPrompt;
  List<BasicUserData> _missingBasicData = [];
  final TextEditingController _chatInputController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _showLoginPrompt = !ref.read(isAuthenticatedProvider);
    _checkMissingHealthData();
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    _chatFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkMissingHealthData() async {
    final healthRepo = ref.read(healthRepositoryProvider);
    final missingFields = await healthRepo.getMissingBasicUserData();

    setState(() {
      _missingBasicData = missingFields;
    });
  }

  void _handleChatSubmit(String text) {
    if (text.trim().isEmpty) return;

    print('User query: $text');
    _chatInputController.clear();

    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('AI is processing your question...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    // Delay for 5 seconds then show the AI response
    Future.delayed(const Duration(seconds: 5), () {
      _showAIResponseBottomSheet(context, text);
    });
  }

  void _showAIResponseBottomSheet(BuildContext context, String userQuestion) {
    // Mock AI responses based on common health questions
    String aiResponse;
    if (userQuestion.toLowerCase().contains('hamburger')) {
      aiResponse =
          '''Based on the health information you've provided, I can offer some general guidance about eating a hamburger:

While an occasional hamburger can be part of a balanced diet, there are a few considerations:

1. **Portion size matters**: A single regular-sized burger is preferable to oversized options.

2. **Consider your toppings**: Vegetables add nutrients, while excessive cheese, bacon, and mayo add calories and saturated fat.

3. **Bun choices**: Whole grain buns provide more fiber than white buns.

4. **Side dish choices**: Consider a side salad instead of fries for a healthier meal overall.

5. **Cooking method**: Grilled is generally healthier than fried.

If you have specific health conditions like heart disease, high cholesterol, or are on a weight management plan, you might want to limit red meat consumption.

Remember, moderation is key - an occasional hamburger is unlikely to cause harm in the context of an otherwise balanced diet.''';
    } else {
      // Generic response for other health questions
      aiResponse =
          '''Thank you for your health question. Based on general health guidelines:

1. Everyone's health needs are different, and what works for one person may not work for another.

2. It's important to maintain a balanced diet rich in fruits, vegetables, whole grains, lean proteins, and healthy fats.

3. Regular physical activity is recommended for most people.

4. Adequate sleep and stress management are crucial components of overall health.

5. For personalized health advice, it's always best to consult with a healthcare professional who knows your specific health history.

Would you like more information on any specific aspect of your health question?''';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, scrollController) => Column(
          children: [
            // Handle bar for dragging
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title with health icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Health AI Response',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // User question
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userQuestion,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            Divider(color: Colors.grey[300], height: 24),
            // AI Response
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Icon(
                          Icons.smart_toy,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          aiResponse,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This information is general guidance and not medical advice. For specific health concerns, please consult a healthcare professional.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DailyUserData> _getDailyUserDataFields() {
    return DailyUserData.values;
  }

  String _getHealthFieldName(BasicUserData field) {
    switch (field) {
      case BasicUserData.height:
        return 'Height';
      case BasicUserData.weight:
        return 'Weight';
      case BasicUserData.dateOfBirth:
        return 'Date of Birth';
      case BasicUserData.gender:
        return 'Gender';
      case BasicUserData.preExistingConditions:
        return 'Health Conditions';
      case BasicUserData.medications:
        return 'Medications';
      case BasicUserData.allergies:
        return 'Allergies';
    }
  }

  IconData _getHealthFieldIcon(BasicUserData field) {
    switch (field) {
      case BasicUserData.height:
        return Icons.height;
      case BasicUserData.weight:
        return Icons.monitor_weight;
      case BasicUserData.dateOfBirth:
        return Icons.cake;
      case BasicUserData.gender:
        return Icons.person;
      case BasicUserData.preExistingConditions:
        return Icons.medical_information;
      case BasicUserData.medications:
        return Icons.medication;
      case BasicUserData.allergies:
        return Icons.coronavirus;
    }
  }

  String _getDailyDataName(DailyUserData field) {
    switch (field) {
      case DailyUserData.nutritionData:
        return 'Nutrition';
      case DailyUserData.moodData:
        return 'Mood';
      case DailyUserData.symptoms:
        return 'Symptoms';
      case DailyUserData.sleepQuality:
        return 'Sleep';
      case DailyUserData.activityData:
        return 'Activity';
    }
  }

  IconData _getDailyDataIcon(DailyUserData field) {
    switch (field) {
      case DailyUserData.nutritionData:
        return Icons.restaurant_menu;
      case DailyUserData.moodData:
        return Icons.mood;
      case DailyUserData.symptoms:
        return Icons.healing;
      case DailyUserData.sleepQuality:
        return Icons.nightlight_round;
      case DailyUserData.activityData:
        return Icons.directions_run;
    }
  }

  Color _getDailyDataColor(DailyUserData field) {
    switch (field) {
      case DailyUserData.nutritionData:
        return AppColors.nutrition;
      case DailyUserData.moodData:
        return AppColors.mood;
      case DailyUserData.symptoms:
        return Colors.redAccent;
      case DailyUserData.sleepQuality:
        return AppColors.sleep;
      case DailyUserData.activityData:
        return AppColors.activity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isAuthenticated && _showLoginPrompt) {
      Future.microtask(() {
        setState(() {
          _showLoginPrompt = false;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_showLoginPrompt)
              LoginPromptCard(
                onDismiss: () => setState(() => _showLoginPrompt = false),
                onLogin: () => context.push('/auth/login'),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, User',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your health journey starts here',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: NavigationCard(
                              title: 'Body Simulator',
                              icon: Icons.accessibility_new,
                              color: AppColors.bodySimulator,
                              onTap: () => context.push('/body-simulator'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: NavigationCard(
                              title: 'Health Logs',
                              icon: Icons.bar_chart,
                              color: AppColors.healthLogs,
                              onTap: () => context.push('/health-logs'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Text(
                          'Complete Your Profile',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Show quick access cards for missing health fields (max 2)
                            if (_missingBasicData.isNotEmpty)
                              for (var field in _missingBasicData.take(2))
                                QuickAccessCard(
                                  title: 'Add ${_getHealthFieldName(field)}',
                                  icon: _getHealthFieldIcon(field),
                                  color: Colors.orange,
                                  onTap: () => context.push('/profile/edit'),
                                ),

                            // Show "See More Health" card if there are more than 2 missing fields
                            if (_missingBasicData.length > 2)
                              QuickAccessCard(
                                title: 'More Health Data',
                                icon: Icons.more_horiz,
                                color: Colors.orange,
                                onTap: () => context.push('/profile/edit'),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Daily Health Tracking Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Text(
                          'Daily Health Tracking',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),

                    // Daily tracking cards
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Always show daily data input cards
                            for (var field in _getDailyUserDataFields())
                              QuickAccessCard(
                                title: _getDailyDataName(field),
                                icon: _getDailyDataIcon(field),
                                color: _getDailyDataColor(field),
                                onTap: () => context.push(
                                    '/${_getDailyDataName(field).toLowerCase()}/log'),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Health insights section
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Text(
                              'Health Insights',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          // Add missing health data insight if there's missing data
                          if (_missingBasicData.isNotEmpty)
                            InsightCard(
                              title: 'Complete Your Health Profile',
                              description:
                                  'Add missing health data to get better insights',
                              icon: Icons.favorite_border,
                              onTap: () => context.push('/profile/edit'),
                            ),
                          InsightCard(
                            title: 'Complete Your Profile',
                            description:
                                'Add more details to get personalized recommendations',
                            icon: Icons.person_add,
                            onTap: () => context.push('/profile'),
                          ),

                          // New chat insights examples
                          InsightCard(
                            title: 'Ask Health Questions',
                            description:
                                'Use the chat below to ask any health questions',
                            icon: Icons.chat,
                            onTap: () {
                              // Focus on the chat input
                              _chatFocusNode.requestFocus();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Add space at the bottom to accommodate the chat input
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Replace FloatingActionButton with chat input
      bottomSheet: Container(
        padding: const EdgeInsets.only(right: 16, left: 16, bottom: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatInputController,
                focusNode: _chatFocusNode,
                decoration: InputDecoration(
                  hintText: 'Ask a health question...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _handleChatSubmit,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: () => _handleChatSubmit(_chatInputController.text),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: null,
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        minHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 1.0,
        maxChildSize: 1.0,
        minChildSize: 1.0,
        builder: (_, scrollController) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: ListView(
            controller: scrollController,
            children: [
              ActionItem(
                icon: Icons.restaurant,
                label: 'Log Meal',
                showInputOnTap: true,
              ),
              ActionItem(
                icon: Icons.monitor_weight,
                label: 'Log Weight',
                showInputOnTap: true,
              ),
              ActionItem(
                icon: Icons.favorite,
                label: 'Log Symptoms',
                showInputOnTap: true,
              ),
              ActionItem(
                icon: Icons.mood,
                label: 'Log Mood',
                showInputOnTap: true,
              ),

              // Divider if there are missing health data items
              if (_missingBasicData.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),

              // Add action items for missing basic health data
              if (_missingBasicData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'Complete Your Profile',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),

              for (var field in _missingBasicData)
                ActionItem(
                  icon: _getHealthFieldIcon(field),
                  label: 'Add ${_getHealthFieldName(field)}',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile/edit');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
