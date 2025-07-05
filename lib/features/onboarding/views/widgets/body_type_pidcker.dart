import 'package:flutter/cupertino.dart';
import 'package:regene/common_libs.dart';

/// 5가지 체형 분류
enum BodyType {
  slim, // 마른 체형
  average, // 평균
  muscular, // 근육질
  overweight, // 과체중
  obese, // 비만
}

/// 현지화된 표시 문자열
extension BodyTypeExtension on BodyType {
  String get displayName {
    switch (this) {
      case BodyType.slim:
        return $strings.bodytype_slim; // ex) "Slim / 마름"
      case BodyType.average:
        return $strings.bodytype_average; // ex) "Average / 평균"
      case BodyType.muscular:
        return $strings.bodytype_muscular; // ex) "Muscular / 근육질"
      case BodyType.overweight:
        return $strings.bodytype_overweight; // ex) "Over-weight / 과체중"
      case BodyType.obese:
        return $strings.bodytype_obese; // ex) "Obese / 비만"
    }
  }
}

/// Cupertino-style picker
class BodyTypePickerWidget extends StatelessWidget {
  const BodyTypePickerWidget({
    super.key,
    required this.selectedBodyType,
    required this.onBodyTypeChanged,
  });

  final BodyType selectedBodyType;
  final ValueChanged<BodyType> onBodyTypeChanged;

  @override
  Widget build(BuildContext context) {
    final bodyTypes = BodyType.values;

    return Column(
      children: [
        Text(
          $strings.select_bodytype, // ex) "Select your body type"
          style: $styles.text.bodySmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: $styles.sizes.maxContentWidth3,
          child: CupertinoPicker(
            itemExtent: $styles.sizes.maxContentWidth3 / 5,
            scrollController: FixedExtentScrollController(
              initialItem: bodyTypes.indexOf(selectedBodyType),
            ),
            onSelectedItemChanged: (idx) => onBodyTypeChanged(bodyTypes[idx]),
            children: bodyTypes
                .map((bt) =>
                    Center(child: Text(bt.displayName, style: $styles.text.h3)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
