import 'package:regene/common_libs.dart';

class MemorizedContextSection extends StatelessWidget {
  final Map<String, dynamic>? memorizedData;
  const MemorizedContextSection({super.key, required this.memorizedData});

  @override
  Widget build(BuildContext context) {
    if (memorizedData == null || memorizedData!.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
        child: Text(
          '아직 기억된 데이터가 없습니다. 아래 채팅을 통해 설정해보세요.',
          style: $styles.text.bodySmall.copyWith(
            color: $styles.colors.caption,
          ),
        ),
      );
    }

    return Column(
      children: memorizedData!.entries.map<Widget>((entry) {
        final key = entry.key;
        final value = entry.value;

        if (value is List && value.isNotEmpty) {
          return ExpansionTile(
            leading: Icon(Icons.info, color: $styles.colors.accent1),
            title: Text(
              _formatDisplayName(key),
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.black,
              ),
            ),
            subtitle: Text(
              '${value.length}개 항목',
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.caption,
              ),
            ),
            children: [
              ...value.map<Widget>((item) => Padding(
                    padding: EdgeInsets.only(
                      left: $styles.insets.lg,
                      right: $styles.insets.md,
                      bottom: $styles.insets.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.fiber_manual_record,
                            size: 8, color: $styles.colors.accent1),
                        SizedBox(width: $styles.insets.sm),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: $styles.text.bodySmall
                                .copyWith(color: $styles.colors.body),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          );
        } else if (value is String && value.isNotEmpty) {
          return ListTile(
            leading: Icon(Icons.info, color: $styles.colors.accent1),
            title: Text(
              _formatDisplayName(key),
              style: $styles.text.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              value,
              style:
                  $styles.text.bodySmall.copyWith(color: $styles.colors.body),
            ),
          );
        } else if (value is Map && value.isNotEmpty) {
          return ExpansionTile(
            initiallyExpanded: true,
            leading: Icon(Icons.info, color: $styles.colors.accent1),
            title: Text(
              _formatDisplayName(key),
              style: $styles.text.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${value.length}개 항목',
              style: $styles.text.bodySmall
                  .copyWith(color: $styles.colors.caption),
            ),
            children: [
              ...value.entries.map<Widget>((subEntry) => Padding(
                    padding: EdgeInsets.only(
                      left: $styles.insets.lg,
                      right: $styles.insets.md,
                      bottom: $styles.insets.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.fiber_manual_record,
                            size: 8, color: $styles.colors.accent1),
                        SizedBox(width: $styles.insets.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDisplayName(subEntry.key),
                                style: $styles.text.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: $styles.colors.accent1,
                                ),
                              ),
                              Text(
                                subEntry.value.toString(),
                                style: $styles.text.bodySmall
                                    .copyWith(color: $styles.colors.body),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          );
        }

        return const SizedBox.shrink();
      }).toList(),
    );
  }

  String _formatDisplayName(String key) {
    return key
        .split('_')
        .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ')
        .trim();
  }
}
