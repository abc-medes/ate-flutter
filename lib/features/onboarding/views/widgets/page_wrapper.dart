import 'package:regene/common_libs.dart';
import 'package:regene/core/widgets/typewriter_animated_text.dart';
import 'package:regene/features/onboarding/view_models/onboarding_view_model.dart';
import 'package:regene/features/onboarding/views/widgets/navigation_hint.dart';

class OnboardingPageWrapper extends StatelessWidget {
  const OnboardingPageWrapper({
    super.key,
    required this.headlineLines,
    required this.state,
    required this.body,
  });

  final List<String> headlineLines;
  final HealthOnboardingState state;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: $styles.insets.md),
        SizedBox(
          height: 120,
          child: TypewriterAnimatedText(
            headlineLines,
            textStyle: $styles.text.h3.copyWith(
              color: $styles.colors.accent1,
            ),
            loop: false,
          ),
        ),
        Expanded(child: body),
        SizedBox(height: $styles.insets.offset),
        NavigationHint(state: state),
      ],
    );
  }
}
