import 'package:flutter/cupertino.dart';
import 'package:bodai/main.dart';

class BirthDatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const BirthDatePickerWidget({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate range for date picker (18-100 years ago)
    final now = DateTime.now();
    final minDate = DateTime(now.year - 100, now.month, now.day);
    final maxDate = DateTime(now.year - 18, now.month, now.day);

    return Column(
      children: [
        Text($strings.select_birthdate,
            style: $styles.text.bodySmall, textAlign: TextAlign.center),
        SizedBox(
          height: $styles.sizes.maxContentWidth3,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: selectedDate,
            minimumDate: minDate,
            maximumDate: maxDate,
            onDateTimeChanged: onDateChanged,
          ),
        ),
      ],
    );
  }
}
