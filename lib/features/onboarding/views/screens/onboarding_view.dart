import 'package:ate_project/core/widgets/typewriter_animated_text.dart';
import 'package:ate_project/features/onboarding/view_models/onboarding_view_model.dart';
import 'package:ate_project/features/onboarding/views/widgets/birth_date_picker.dart';
import 'package:ate_project/features/onboarding/views/widgets/height_picker.dart';
import 'package:ate_project/features/onboarding/views/widgets/weight_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/data/models/health_model.dart';

// Create a provider for tracking current page
final onboardingPageProvider = StateProvider<int>((ref) => 0);

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  OnboardingViewState createState() => OnboardingViewState();
}

class OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  final List<BasicUserData> _onboardingSteps = [
    BasicUserData.height, // Combined with weight
    BasicUserData.dateOfBirth,
    BasicUserData.gender,
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int newPage = _pageController.page?.round() ?? 0;
      int currentPage = ref.read(onboardingPageProvider);
      if (newPage != currentPage) {
        ref.read(onboardingPageProvider.notifier).state = newPage;
        _saveCurrentPageData(currentPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _saveCurrentPageData(int pageIndex) async {
    final viewModel = ref.read(healthOnboardingProvider.notifier);

    switch (pageIndex) {
      case 0:
        await viewModel.saveHeightandWeightData();
        break;
      case 1:
        await viewModel.saveBirthDate();
        break;
      // case 2:
      //   await viewModel.saveGender();
      //   break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for state changes
    final viewModel = ref.watch(healthOnboardingProvider.notifier);
    final state = ref.watch(healthOnboardingProvider);
    final currentPage = ref.watch(onboardingPageProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(_onboardingSteps.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Main content
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      currentPage == _onboardingSteps.length - 1) {
                    if (notification.metrics.pixels >
                        notification.metrics.maxScrollExtent - 20) {
                      return true;
                    }
                  }
                  return false;
                },
                child: PageView(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  children: [
                    _buildHeightWeightPage(context, viewModel, state),
                    _buildDateOfBirthPage(context, viewModel, state),
                    _buildGenderPage(context, viewModel, state),
                  ],
                ),
              ),
            ),

            // Navigation hint or action
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Column(
                    children: [
                      Icon(
                        currentPage < _onboardingSteps.length - 1
                            ? Icons.arrow_downward
                            : Icons
                                .arrow_downward, // Change to check icon if you want
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentPage < _onboardingSteps.length - 1
                            ? "Scroll down to continue"
                            : "Scroll down to save", // Updated text
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Back hint
                  if (currentPage > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Scroll up to go back",
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // Show saving indicator if in progress
                  if (state.isSaving)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Saving...",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
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

  // Height & Weight page
  Widget _buildHeightWeightPage(BuildContext context,
      HealthOnboardingViewModel viewModel, HealthOnboardingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const TypewriterAnimatedText(
            ["Set up your profile"],
            textStyle: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            loop: false,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Height',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        '${state.selectedHeight} cm',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      Text('Weight',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        '${state.selectedWeight} kg',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: HeightPickerWidget(
                    selectedHeight: state.selectedHeight,
                    onHeightChanged: viewModel.updateHeight,
                  ),
                ),
                Expanded(
                  child: WeightPickerWidget(
                    selectedWeight: state.selectedWeight,
                    onWeightChanged: viewModel.updateWeight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Date of Birth page
  Widget _buildDateOfBirthPage(BuildContext context,
      HealthOnboardingViewModel viewModel, HealthOnboardingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            "When were you born?",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: BirthDatePickerWidget(
                    selectedDate: state.selectedBirthDate,
                    onDateChanged: viewModel.updateBirthDate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Gender page
  Widget _buildGenderPage(BuildContext context,
      HealthOnboardingViewModel viewModel, HealthOnboardingState state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          Text(
            "What's your gender?",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            "This helps us provide more relevant health recommendations",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 36),

          // Gender selection (placeholder)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Select Gender",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  // Replace with actual gender selection
                  SizedBox(
                    height: 160,
                    child: Center(
                      child: Text(
                        "Gender Selection Widget\nWill Go Here",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Extra space at bottom to enable scrolling all the way down
          const SizedBox(height: 150),
        ],
      ),
    );
  }
}
