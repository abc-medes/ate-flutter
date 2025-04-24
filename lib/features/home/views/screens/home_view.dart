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
  bool _isLoadingHealthData = true;

  @override
  void initState() {
    super.initState();
    _showLoginPrompt = !ref.read(isAuthenticatedProvider);
    _checkMissingHealthData();
  }

  Future<void> _checkMissingHealthData() async {
    final healthRepo = ref.read(healthRepositoryProvider);
    final missingFields = await healthRepo.getMissingBasicUserData();

    setState(() {
      _missingBasicData = missingFields;
      _isLoadingHealthData = false;
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

                    // Section title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Text(
                          'Quick Access',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),

                    // Quick access cards
                    // TODO: Add quick access cards for missing health fields
                    // SliverToBoxAdapter(
                    //   child: SizedBox(
                    //     height: 110,
                    //     child: ListView(
                    //       scrollDirection: Axis.horizontal,
                    //       children: [
                    //         // Show quick access cards for missing health fields (max 2)
                    //         if (_missingBasicData.isNotEmpty)
                    //           for (var field in _missingBasicData.take(2))
                    //             QuickAccessCard(
                    //               title: 'Add ${_getHealthFieldName(field)}',
                    //               icon: _getHealthFieldIcon(field),
                    //               color: Colors.orange,
                    //               onTap: () => context.push('/profile/edit'),
                    //             ),

                    //         // Show "See More Health" card if there are more than 2 missing fields
                    //         if (_missingBasicData.length > 2)
                    //           QuickAccessCard(
                    //             title: 'More Health Data',
                    //             icon: Icons.more_horiz,
                    //             color: Colors.orange,
                    //             onTap: () => context.push('/profile/edit'),
                    //           ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionItem(
                icon: Icons.restaurant,
                label: 'Log Meal',
                onTap: () {},
              ),
              ActionItem(
                icon: Icons.monitor_weight,
                label: 'Log Weight',
                onTap: () {},
              ),
              ActionItem(
                icon: Icons.favorite,
                label: 'Log Symptoms',
                onTap: () {},
              ),
              ActionItem(
                icon: Icons.mood,
                label: 'Log Mood',
                onTap: () {},
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

// Login prompt widget
class LoginPromptCard extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onLogin;

  const LoginPromptCard({
    Key? key,
    required this.onDismiss,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sign in for personalized experience',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Create an account to save your health data and get insights tailored to you.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sign In / Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

// Large navigation card widget
class NavigationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const NavigationCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quick access card widget
class QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAccessCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Insight card widget
class InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const InsightCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Action item for bottom sheet
class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}
