import 'package:flutter/cupertino.dart';
import 'package:regene/common_libs.dart';

enum Gender {
  male,
  female,
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return $strings.gender_male;
      case Gender.female:
        return $strings.gender_female;
    }
  }
}

class GenderPickerWidget extends StatelessWidget {
  final Gender selectedGender;
  final Function(Gender) onGenderChanged;

  const GenderPickerWidget({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final genders = Gender.values;

    return Column(
      children: [
        Text($strings.select_gender,
            style: $styles.text.bodySmall, textAlign: TextAlign.center),
        SizedBox(
          height: $styles.sizes.maxContentWidth3,
          child: CupertinoPicker(
            itemExtent: $styles.sizes.maxContentWidth3 / 5,
            scrollController: FixedExtentScrollController(
              initialItem: genders.indexOf(selectedGender),
            ),
            onSelectedItemChanged: (index) {
              onGenderChanged(genders[index]);
            },
            children: genders.map((gender) {
              return Center(
                child: Text(
                  gender.displayName,
                  style: $styles.text.h3,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
