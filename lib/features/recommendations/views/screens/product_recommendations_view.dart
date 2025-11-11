import 'package:bodido/common_libs.dart';

class ProductRecommendationsView extends StatelessWidget {
  const ProductRecommendationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Center(
        child: Text(
          'Food Recommendations',
          style: $styles.text.h3,
        ),
      ),
    );
  }
}
