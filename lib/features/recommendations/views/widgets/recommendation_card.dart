import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/product_recommendations_model.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.item,
    this.linkBinding,
  });

  final ProductRecommendationItem item;
  final Map<String, dynamic>? linkBinding;

  Uri? _affiliateUri() {
    final url = linkBinding?['affiliate_url']?.toString();
    if (url == null || url.isEmpty) return null;
    return Uri.tryParse(url);
  }

  Future<void> _openAffiliate(BuildContext context) async {
    final uri = _affiliateUri();
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            $strings.couldNotOpenUrl(uri.toString()),
            style: $styles.text.body.copyWith(color: $styles.colors.white),
          ),
          backgroundColor: $styles.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAffiliate = _affiliateUri() != null;
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
                        $strings.recs_priority(item.priority),
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
            Text(item.productName, style: $styles.text.h3, softWrap: true),
            SizedBox(height: $styles.insets.sm),
            if (item.whyItHelps.isNotEmpty) ...[
              Text(
                item.whyItHelps,
                style: $styles.text.body.copyWith(color: $styles.colors.body),
                softWrap: true,
              ),
              SizedBox(height: $styles.insets.md),
            ],
            if (item.keyBenefits.isNotEmpty) ...[
              Text($strings.recs_key_benefits, style: $styles.text.bodyBold),
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
                      Expanded(child: Text(b, style: $styles.text.body)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: $styles.insets.md),
            ],
            if (item.recommendedUseCases.isNotEmpty) ...[
              Text($strings.recs_recommended_use, style: $styles.text.bodyBold),
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
                      Expanded(child: Text(u, style: $styles.text.body)),
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
                      style: $styles.text.caption
                          .copyWith(color: $styles.colors.caption),
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
              Text($strings.recs_notes, style: $styles.text.bodyBold),
              SizedBox(height: $styles.insets.xs),
              Text(item.additionalNotes!, style: $styles.text.body),
            ],
            if (hasAffiliate) ...[
              SizedBox(height: $styles.insets.md),
              Row(
                children: [
                  Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => _openAffiliate(context),
                    icon: Icon(Icons.open_in_new,
                        size: 18, color: $styles.colors.accent1),
                    label: Text(
                      $strings.recs_open_link,
                      style: $styles.text.bodySmall
                          .copyWith(color: $styles.colors.accent1),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: $styles.colors.accent1.withOpacity(0.5),
                          width: 1),
                    ),
                  ),
                ],
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
            label.isEmpty ? $strings.recs_category_fallback : label,
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
