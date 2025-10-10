import 'package:bodido/common_libs.dart';

class PolicyViewerSheet extends StatelessWidget {
  final String title;
  final String assetPath;
  const PolicyViewerSheet({super.key, required this.title, required this.assetPath});

  static Future<void> show(BuildContext context,
      {required String title, required String assetPath}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular($styles.corners.md)),
      ),
      builder: (ctx) => PolicyViewerSheet(title: title, assetPath: assetPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: $styles.colors.background,
        padding: EdgeInsets.all($styles.insets.md),
        height: MediaQuery.of(context).size.height * 0.75,
        child: FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString(assetPath),
          builder: (context, snap) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: $styles.text.h3.copyWith(color: $styles.colors.accent1)),
                SizedBox(height: $styles.insets.sm),
                Expanded(
                  child: snap.hasData
                      ? SingleChildScrollView(
                          child: SelectableText(
                            snap.data!,
                            style: $styles.text.bodySmall.copyWith(color: $styles.colors.body),
                          ),
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}