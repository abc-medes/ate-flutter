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
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.caption,
              ),
            ),
          ),
        ],
      );
    }

    // Sort: bad first, then higher priority
    int rank(InsightItem i) => _isGoodValue(i.value) ? 1 : 0;
    final sorted = [...widget.insights]..sort((a, b) {
        final r = rank(a).compareTo(rank(b));
        if (r != 0) return r;
        return b.priority.compareTo(a.priority);
      });

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: sorted.length,
            onPageChanged: (index) => setState(() => _current = index),
            itemBuilder: (context, index) {
              final i = sorted[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
                child: InsightCard(
                  icon: i.iconData,
                  title: i.title,
                  value: i.value,
                  advice: i.advice,
                  isGood: _isGoodValue(i.value),
                ),
              );
            },
          ),
        ),
        SizedBox(height: $styles.insets.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sorted.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _current
                    ? $styles.colors.accent1
                    : $styles.colors.greyMedium,
              ),
            ),
          ),
        ),
      ],
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
