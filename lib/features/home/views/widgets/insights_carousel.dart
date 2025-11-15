import 'package:bodido/common_libs.dart';
import 'package:bodido/data/models/insight_model.dart';

class InsightsCarousel extends StatefulWidget {
  final List<InsightItem> insights;
  final double height;
  const InsightsCarousel(
      {super.key, required this.insights, this.height = 220});

  @override
  State<InsightsCarousel> createState() => _InsightsCarouselState();
}

class _InsightsCarouselState extends State<InsightsCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final insights = widget.insights;

    if (insights.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
              child: _skeletonCard(),
            ),
          ),
          SizedBox(height: $styles.insets.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Text(
              '인사이트를 불러오는 중입니다...',
              textAlign: TextAlign.start,
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.caption,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            itemCount: insights.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
                child: _insightCard(
                  insight.iconData,
                  insight.title,
                  insight.value,
                  insight.advice,
                ),
              );
            },
          ),
        ),
        SizedBox(height: $styles.insets.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            insights.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentPage
                    ? $styles.colors.accent1
                    : $styles.colors.greyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _insightCard(
      IconData icon, String title, String value, String advice) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all($styles.insets.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: $styles.colors.accent1),
                SizedBox(width: $styles.insets.sm),
                Expanded(
                  child: Text(
                    title,
                    style: $styles.text.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: $styles.text.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: $styles.colors.accent1,
                  ),
                ),
              ],
            ),
            SizedBox(height: $styles.insets.sm),
            Text(
              advice,
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.body,
                height: 1.3,
              ),
            ),
          ],
        ),
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
