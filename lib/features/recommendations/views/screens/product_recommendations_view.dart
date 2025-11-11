import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';

class ProductRecommendationsView extends StatelessWidget {
  const ProductRecommendationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Center(
              child: Text(
                'Product Recommendations',
                style: $styles.text.h3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        mq.padding.top,
        $styles.insets.md,
        $styles.insets.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularIconButton(
            icon: Icons.arrow_back,
            size: 48,
            iconColor: $styles.colors.black,
            backgroundColor: Colors.transparent,
            onTap: () => context.go(RouteNames.home),
          ),
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined),
              SizedBox(width: $styles.insets.sm),
              Text(
                'Product Recommendations',
                style: $styles.text.bodySmall,
              ),
            ],
          ),
          CircularIconButton(
            size: 48,
            icon: Icons.settings,
            iconColor: $styles.colors.black,
            backgroundColor: Colors.transparent,
            onTap: () => context.go(RouteNames.settings),
          ),
        ],
      ),
    );
  }
}
