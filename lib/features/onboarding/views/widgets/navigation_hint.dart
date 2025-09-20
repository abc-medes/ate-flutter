import 'package:bodido/common_libs.dart';
import 'package:bodido/features/onboarding/view_models/onboarding_view_model.dart';

class NavigationHint extends StatelessWidget {
  const NavigationHint({super.key, required this.state});
  final HealthOnboardingState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: $styles.insets.xs),
      child: Column(
        children: [
          if (!state.isSaving) ...[
            Column(
              children: [
                Icon(Icons.arrow_downward,
                    size: 32, color: Theme.of(context).colorScheme.primary),
                SizedBox(height: $styles.insets.sm),
                Text(
                  "Scroll down to save and continue",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            if (state.currentPage > 0)
              Padding(
                padding: EdgeInsets.only(top: $styles.insets.sm),
                child: Text(
                  "Scroll up to go back",
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
          if (state.isSaving)
            Padding(
              padding: EdgeInsets.only(top: $styles.insets.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text("Saving...",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
