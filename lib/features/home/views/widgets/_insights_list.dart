import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/insight_model.dart';
import 'package:bodido/features/home/views/widgets/insight_card.dart';

class InsightsList extends StatefulWidget {
  final List<InsightItem> insights;
  final bool isLoading;
  final double height;

  const InsightsList({
    super.key,
    required this.insights,
    required this.isLoading,
    this.height = 220,
  });

  @override
  State<InsightsList> createState() => _InsightsListState();
}

class _InsightsListState extends State<InsightsList> {
  bool _isGoodValue(String v) {
    final s = v.toLowerCase();
    return s.contains('좋음') ||
        s.contains('양호') ||
        s.contains('good') ||
        s.contains('great') ||
        s.contains('excellent');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading || widget.insights.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Column(
              children: [
                _skeletonCard(),
                SizedBox(height: $styles.insets.sm),
                _skeletonCard(),
              ],
            ),
          ),
          SizedBox(height: $styles.insets.xs),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Text('인사이트를 불러오는 중입니다...',
                style: $styles.text.bodySmall
                    .copyWith(color: $styles.colors.caption)),
          ),
        ],
      );
    }

    // Sort: good first (bad last), then higher priority
    int rank(InsightItem i) => _isGoodValue(i.value) ? 0 : 1;
    final sorted = [...widget.insights]..sort((a, b) {
        final r = rank(a).compareTo(rank(b));
        if (r != 0) return r;
        return b.priority.compareTo(a.priority);
      });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: sorted.length,
        separatorBuilder: (_, __) => SizedBox(height: $styles.insets.sm),
        itemBuilder: (context, index) {
          final i = sorted[index];
          return InsightCard(
            icon: i.iconData,
            title: i.title,
            value: i.value,
            advice: i.advice,
            isGood: _isGoodValue(i.value),
          );
        },
      ),
    );
  }

  Widget _skeletonCard() {
    return Card(
      elevation: 8,
      shadowColor: $styles.colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($styles.corners.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all($styles.insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: $styles.colors.greyMedium,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: $styles.insets.md),
                Expanded(
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: $styles.colors.greyMedium,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: $styles.colors.greyMedium,
                    borderRadius: BorderRadius.circular($styles.corners.sm),
                  ),
                ),
              ],
            ),
            SizedBox(height: $styles.insets.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                3,
                (index) => Container(
                  width: double.infinity,
                  height: 16,
                  margin: EdgeInsets.only(bottom: index < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: $styles.colors.greyMedium,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
