import 'package:flutter/cupertino.dart';

enum Gender {
  male,
  female,
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
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
        SizedBox(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 40,
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
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
