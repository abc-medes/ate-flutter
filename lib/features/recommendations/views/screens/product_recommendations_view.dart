import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/circular_icon_button.dart';
import 'package:bodido/features/recommendations/view_models/product_view_model.dart';
import 'package:bodido/data/models/product_recommendations_model.dart';

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
                        'No product recommendations yet',
                        style: $styles.text.body,
                      ),
                    );
                  }

                  // Responsive, single scrollable ListView (no overflow)
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
                          return _RecommendationCard(item: item);
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
                    'Product Recommendations',
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

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.item});

  final ProductRecommendationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: $styles.colors.backgroundDark,
        borderRadius: BorderRadius.circular($styles.corners.md),
        border: Border.all(
          color: $styles.colors.accent1.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: $styles.colors.accent1.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all($styles.insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryChip(label: item.category),
                SizedBox(width: $styles.insets.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: $styles.insets.sm,
                    vertical: $styles.insets.xxs,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($styles.corners.sm),
                    color: $styles.colors.caption.withOpacity(0.15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: $styles.colors.accent1),
                      SizedBox(width: $styles.insets.xxs),
                      Text(
                        'Priority ${item.priority}',
                        style: $styles.text.caption.copyWith(
                          color: $styles.colors.body,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                if (item.approxPriceRange != null &&
                    item.approxPriceRange!.isNotEmpty)
                  Flexible(
                    child: Text(
                      item.approxPriceRange!,
                      style: $styles.text.bodySmall.copyWith(
                        color: $styles.colors.accent1,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
            SizedBox(height: $styles.insets.md),
            Text(
              item.productName,
              style: $styles.text.h3,
              softWrap: true,
            ),
            SizedBox(height: $styles.insets.sm),
            if (item.whyItHelps.isNotEmpty) ...[
              Text(
                item.whyItHelps,
                style: $styles.text.body.copyWith(
                  color: $styles.colors.body,
                ),
                softWrap: true,
              ),
              SizedBox(height: $styles.insets.md),
            ],
            if (item.keyBenefits.isNotEmpty) ...[
              Text(
                'Key benefits',
                style: $styles.text.bodyBold,
              ),
              SizedBox(height: $styles.insets.xs),
              ...item.keyBenefits.map(
                (b) => Padding(
                  padding: EdgeInsets.only(bottom: $styles.insets.xxs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          size: 18, color: $styles.colors.accent2),
                      SizedBox(width: $styles.insets.xs),
                      Expanded(
                        child: Text(
                          b,
                          style: $styles.text.body,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: $styles.insets.md),
            ],
            if (item.recommendedUseCases.isNotEmpty) ...[
              Text(
                'Recommended use',
                style: $styles.text.bodyBold,
              ),
              SizedBox(height: $styles.insets.xs),
              ...item.recommendedUseCases.map(
                (u) => Padding(
                  padding: EdgeInsets.only(bottom: $styles.insets.xxs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule,
                          size: 18, color: $styles.colors.accent3),
                      SizedBox(width: $styles.insets.xs),
                      Expanded(
                        child: Text(
                          u,
                          style: $styles.text.body,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: $styles.insets.sm),
            ],
            if (item.searchKeywords.isNotEmpty) ...[
              Wrap(
                spacing: $styles.insets.xs,
                runSpacing: $styles.insets.xs,
                children: item.searchKeywords.take(8).map((k) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: $styles.insets.xs,
                      vertical: $styles.insets.xxs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($styles.corners.sm),
                      color: $styles.colors.caption.withOpacity(0.12),
                    ),
                    child: Text(
                      k,
                      style: $styles.text.caption.copyWith(
                        color: $styles.colors.caption,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  );
                }).toList(),
              ),
            ],
            if (item.additionalNotes != null &&
                item.additionalNotes!.trim().isNotEmpty) ...[
              SizedBox(height: $styles.insets.md),
              Text(
                'Notes',
                style: $styles.text.bodyBold,
              ),
              SizedBox(height: $styles.insets.xs),
              Text(
                item.additionalNotes!,
                style: $styles.text.body,
                softWrap: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.sm,
        vertical: $styles.insets.xxs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular($styles.corners.sm),
        color: $styles.colors.accent1.withOpacity(0.15),
        border: Border.all(
          color: $styles.colors.accent1.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category, size: 16, color: $styles.colors.accent1),
          SizedBox(width: $styles.insets.xxs),
          Text(
            label.isEmpty ? 'item' : label,
            style: $styles.text.caption.copyWith(
              color: $styles.colors.accent1,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}
