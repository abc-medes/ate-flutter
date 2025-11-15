import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';
import 'package:bodido/features/recommendations/view_models/product_view_model.dart';
import 'package:bodido/data/models/product_recommendations_model.dart';
import 'package:bodido/features/recommendations/views/widgets/recommendation_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductRecommendationsView extends ConsumerWidget {
  const ProductRecommendationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productRecommendationsViewModelProvider);

    final items = state.items
        .map((row) => ProductRecommendationsRow.fromJson(
              Map<String, dynamic>.from(row),
            ))
        .expand((r) => r.recommendations)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    String _normalizeTitle(String v) =>
        v.toLowerCase().replaceAll(RegExp(r'[^가-힣a-z0-9]+'), '');

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: $styles.insets.sm),
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all($styles.insets.md),
                        child: Text(
                          state.error!,
                          style: $styles.text.body,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        $strings.recs_empty,
                        style: $styles.text.body,
                      ),
                    );
                  }

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 720),
                      child: ListView.separated(
                        padding: EdgeInsets.all($styles.insets.md),
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: $styles.insets.md),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final key = item.bindingId;
                          final link =
                              key == null ? null : state.linksByBindingId[key];
                          return RecommendationCard(
                              item: item, linkBinding: link);
                        },
                      ),
                    ),
                  );
                },
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined),
                SizedBox(width: $styles.insets.sm),
                Flexible(
                  child: Text(
                    $strings.recs_title,
                    style: $styles.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
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
