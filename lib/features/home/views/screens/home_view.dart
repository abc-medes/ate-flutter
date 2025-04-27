import 'package:ate_project/core/widgets/ai_response_bottom_sheet.dart';
import 'package:ate_project/core/widgets/chat_input.dart';
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
  final FocusNode _chatFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _showLoginPrompt = !ref.read(isAuthenticatedProvider);
    _checkMissingHealthData();
  }

  @override
  void dispose() {
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

  void _onChatSubmit(String text) {
    print('User query: $text');

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
      AIResponseBottomSheet.show(context, text);
    });
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
      bottomSheet: HealthChatInput(
        onSubmit: _onChatSubmit,
      ),
    );
  }
}
