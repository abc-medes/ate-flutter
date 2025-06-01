import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/core/widgets/typewriter_animated_text.dart';
import 'package:ate_project/features/onboarding/view_models/onboarding_view_model.dart';
import 'package:ate_project/features/onboarding/views/widgets/birth_date_picker.dart';
import 'package:ate_project/features/onboarding/views/widgets/gender_picker.dart';
import 'package:ate_project/features/onboarding/views/widgets/height_picker.dart';
import 'package:ate_project/features/onboarding/views/widgets/weight_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/data/models/health_model.dart';
import 'package:go_router/go_router.dart';

final onboardingPageProvider = StateProvider<int>((ref) => 0);

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  OnboardingViewState createState() => OnboardingViewState();
}

class OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  final List<BasicUserData> _onboardingSteps = [
    BasicUserData.gender,
    BasicUserData.dateOfBirth,
    BasicUserData.height,
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int newPage = _pageController.page?.round() ?? 0;
      int currentPage = ref.read(healthOnboardingProvider).currentPage;
      if (newPage != currentPage) {
        ref.read(healthOnboardingProvider.notifier).updateCurrentPage(newPage);
        if (newPage > currentPage) {
          _saveCurrentPageData(currentPage);
        }
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
        await viewModel.saveGender();
        break;
      case 1:
        await viewModel.saveBirthDate();
        break;
      case 2:
        await viewModel.saveHeightandWeightData();
        await viewModel.createChatRoom();
        break;
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
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                children: [
                  _buildGenderPage(context, viewModel, state),
                  _buildDateOfBirthPage(context, viewModel, state),
                  _buildHeightWeightPage(context, viewModel, state),
                  _buildRedirectPage(),
                  // _buildPreExistingConditionsPage(context, viewModel, state),
                  // _buildMedicationsPage(context, viewModel, state),
                  // _buildAllergiesPage(context, viewModel, state),
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
          SizedBox(
            height: 80,
            child: TypewriterAnimatedText(
              [
                "Your body shape completes the picture.",
                "Let's understand how you carry your energy."
              ],
              textStyle: Theme.of(context).textTheme.headlineMedium!,
              loop: false,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
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
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
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
              ],
            ),
          ),
          const SizedBox(height: 100),
          _buildNavigationHint(state),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          SizedBox(
            height: 80,
            child: TypewriterAnimatedText(
              [
                "Your age guides how your body recovers.",
                "Small number with big meaning."
              ],
              textStyle: Theme.of(context).textTheme.headlineMedium!,
              loop: false,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your birth date?",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
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
              ],
            ),
          ),
          const SizedBox(height: 100),
          _buildNavigationHint(state),
        ],
      ),
    );
  }

  // Gender page
  Widget _buildGenderPage(BuildContext context,
      HealthOnboardingViewModel viewModel, HealthOnboardingState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 80,
          child: TypewriterAnimatedText(
            ["We'll tune your insights with care.", "As uniquely as you are."],
            textStyle: Theme.of(context).textTheme.headlineMedium!,
            loop: false,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your gender?",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              // const SizedBox(height: 36),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: GenderPickerWidget(
                        selectedGender: state.selectedGender,
                        onGenderChanged: viewModel.updateGender,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 150),
        // Navigation hint or action
        _buildNavigationHint(state),
      ],
    );
  }

  Widget _buildRedirectPage() {
    final viewModel = ref.read(healthOnboardingProvider.notifier);
    final state = ref.watch(healthOnboardingProvider);

    if (state.isSaving) {
      return const Center(child: CircularProgressIndicator());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && context.mounted) {
        context.go(RouteNames.home);
      }
    });

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildNavigationHint(HealthOnboardingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Column(
            children: [
              Icon(
                Icons.arrow_downward,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                "Scroll down to save and continue",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          // Back hint
          if (state.currentPage > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Scroll up to go back",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
    );
  }
}
