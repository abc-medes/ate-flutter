import 'package:bodai/common_libs.dart';

class InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String advice;
  final bool isGood; // Add this parameter

  const InsightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.advice,
    required this.isGood, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    // Choose color based on good/bad state
    final cardColor = isGood ? $styles.colors.accent1 : $styles.colors.accent2;
    final textColor =
        $styles.colors.white; // White text for contrast on both colors

    return Card(
      color: cardColor,
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all($styles.insets.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: textColor, // Icon color matches text color
                ),
                SizedBox(width: $styles.insets.sm),
                Expanded(
                  child: Text(
                    title,
                    style: $styles.text.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: $styles.text.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: $styles.insets.sm),
            Text(
              advice,
              style: $styles.text.bodySmall.copyWith(
                color: textColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
