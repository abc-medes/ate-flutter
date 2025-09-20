import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/live_typewriter.dart';
import 'package:bodido/features/onboarding/view_models/onboarding_view_model.dart';
import 'package:bodido/features/onboarding/views/widgets/birth_date_picker.dart';
import 'package:bodido/features/onboarding/views/widgets/body_type_pidcker.dart';
import 'package:bodido/features/onboarding/views/widgets/gender_picker.dart';
import 'package:bodido/features/onboarding/views/widgets/height_picker.dart';
import 'package:bodido/features/onboarding/views/widgets/page_wrapper.dart';
import 'package:bodido/features/onboarding/views/widgets/weight_picker.dart';
import 'package:bodido/data/models/health_model.dart';

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
    BasicUserData.bodyType,
  ];
  bool _wrapUpTriggered = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() async {
      int newPage = _pageController.page?.round() ?? 0;
      int currentPage = ref.read(healthOnboardingProvider).currentPage;
      if (newPage != currentPage) {
        if (newPage != _onboardingSteps.length) {
          _wrapUpTriggered = false;
          ref.read(healthOnboardingProvider.notifier).clearProgressMessages();
        }

        ref.read(healthOnboardingProvider.notifier).updateCurrentPage(newPage);
        if (newPage > currentPage) {
          await _saveCurrentPageData(currentPage);
        }

        if (newPage == _onboardingSteps.length && !_wrapUpTriggered) {
          _wrapUpTriggered = true;
          await _saveCurrentPageData(_onboardingSteps.length - 1);
          ref.read(healthOnboardingProvider.notifier).finalizeOnboarding();
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentPageData(int pageIndex) async {
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
        break;
      case 3:
        await viewModel.saveBodyType();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for state changes
    final viewModel = ref.watch(healthOnboardingProvider.notifier);
    final state = ref.watch(healthOnboardingProvider);
    final currentPage =
        ref.watch(healthOnboardingProvider.select((s) => s.currentPage));

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all($styles.insets.md),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: List.generate(_onboardingSteps.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= currentPage
                            ? $styles.colors.accent1
                            : $styles.colors.offWhite,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
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
                    _buildBodyTypePage(context, viewModel, state),
                    _buildRedirectPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderPage(BuildContext context,
      HealthOnboardingViewModel viewModel, HealthOnboardingState state) {
    return OnboardingPageWrapper(
      headlineLines: [
        $strings.onboarding_gender,
      ],
      state: state,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GenderPickerWidget(
            selectedGender: state.selectedGender,
            onGenderChanged: viewModel.updateGender,
          ),
        ],
      ),
    );
  }

  // Date of Birth page
  Widget _buildDateOfBirthPage(BuildContext context,
      HealthOnboardingViewModel viewModel, HealthOnboardingState state) {
    return OnboardingPageWrapper(
      headlineLines: [
        $strings.onboarding_birth,
      ],
      state: state,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BirthDatePickerWidget(
            selectedDate: state.selectedBirthDate,
            onDateChanged: viewModel.updateBirthDate,
          ),
        ],
      ),
    );
  }

  // Height & Weight page
  Widget _buildHeightWeightPage(BuildContext context,
      HealthOnboardingViewModel viewModel, HealthOnboardingState state) {
    return OnboardingPageWrapper(
      headlineLines: [
        $strings.onboarding_bodymetrics,
      ],
      state: state,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text($strings.select_hw,
              style: $styles.text.bodySmall, textAlign: TextAlign.center),
          Row(
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
        ],
      ),
    );
  }

  Widget _buildBodyTypePage(BuildContext context,
      HealthOnboardingViewModel viewModel, HealthOnboardingState state) {
    return OnboardingPageWrapper(
      headlineLines: [
        $strings.onboarding_bodytype_dynamic(
          state.selectedHeight, // height  인자
          state.selectedWeight, // weight 인자
        ),
      ],
      state: state,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BodyTypePickerWidget(
            selectedBodyType: state.selectedBodyType,
            onBodyTypeChanged: viewModel.updateBodyType,
          ),
        ],
      ),
    );
  }

  Widget _buildRedirectPage() {
    final state = ref.watch(healthOnboardingProvider);

    List<String> logs =
        state.progressMessages.isEmpty ? [] : state.progressMessages;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LiveTypewriter(
          lines: logs,
          expectedLineCount: 2,
          onComplete: _scheduleNavigation,
          charDelay: const Duration(milliseconds: 50),
          linePause: const Duration(milliseconds: 200),
          style: $styles.text.h4.copyWith(
            color: $styles.colors.accent1,
          ),
        ),
        SizedBox(height: $styles.insets.md),
        if (state.isSaving) const CircularProgressIndicator(),
      ],
    );
  }

  void _scheduleNavigation() {
    if (mounted && context.mounted) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        context.go(RouteNames.home);
      });
    }
  }
}
