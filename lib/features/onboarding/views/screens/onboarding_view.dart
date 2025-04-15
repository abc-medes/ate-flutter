import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/core/services/user_service.dart';
import 'package:go_router/go_router.dart';

class OnboardingView extends ConsumerWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final user = userState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: userState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      Text(
                        'Welcome${user?.name != null ? ", ${user!.name}" : ""}!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Let\'s complete your profile to get started.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Display current profile info
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildProfileItem(
                                'Email',
                                user?.email ?? 'Not provided',
                              ),
                              const Divider(),
                              _buildProfileItem(
                                'Name',
                                user?.name ?? 'Not provided',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Steps to complete
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Steps to Complete',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStepItem(
                                'Personal Information',
                                user?.onboardingStatus.personalInfoCompleted ??
                                    false,
                                onTap: () => _completeStep(
                                    ref,
                                    'personal_info',
                                    user?.onboardingStatus
                                            .personalInfoCompleted ??
                                        false),
                              ),
                              const SizedBox(height: 8),
                              _buildStepItem(
                                'Health Profile',
                                user?.onboardingStatus.healthProfileCompleted ??
                                    false,
                                onTap: () => _completeStep(
                                    ref,
                                    'health_profile',
                                    user?.onboardingStatus
                                            .healthProfileCompleted ??
                                        false),
                              ),
                              const SizedBox(height: 8),
                              _buildStepItem(
                                'Set Your Goals',
                                user?.onboardingStatus.goalsCompleted ?? false,
                                onTap: () => _completeStep(
                                    ref,
                                    'goals',
                                    user?.onboardingStatus.goalsCompleted ??
                                        false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // For now, just mark all steps as completed and continue
                            _completeAllSteps(ref, context);
                          },
                          child: const Text(
                            'Continue to App',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String label, bool isCompleted,
      {required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted
                ? AppColors.success
                : AppColors.textTertiary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? AppColors.success : AppColors.textTertiary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _completeStep(WidgetRef ref, String step, bool isAlreadyCompleted) {
    if (!isAlreadyCompleted) {
      final notifier = ref.read(userProvider.notifier);
      notifier.completeOnboardingStep(step);
    }
    // In a real app, navigate to the specific step form
  }

  void _completeAllSteps(WidgetRef ref, BuildContext context) {
    final userId = ref.read(userProvider).user?.id;
    if (userId != null) {
      // Mark all steps as completed for demo purposes
      // final userService = ref.read(userServiceProvider);
      // userService.completeOnboardingStep(userId, 'personal_info');
      // userService.completeOnboardingStep(userId, 'health_profile');
      // userService.completeOnboardingStep(userId, 'goals');

      // Navigate to home
      context.go(RouteNames.home);
    }
  }
}
