import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bodido/main.dart';

class WeightPickerWidget extends StatelessWidget {
  final int selectedWeight;
  final Function(int) onWeightChanged;

  const WeightPickerWidget({
    super.key,
    required this.selectedWeight,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final weightOptions =
        List.generate(151, (index) => index + 30); // 30-180 kg

    return Column(
      children: [
        SizedBox(
          height: $styles.sizes.maxContentWidth3,
          child: CupertinoPicker(
            itemExtent: $styles.sizes.maxContentWidth3 / 6,
            scrollController: FixedExtentScrollController(
              initialItem: weightOptions.indexOf(selectedWeight),
            ),
            onSelectedItemChanged: (index) {
              onWeightChanged(weightOptions[index]);
            },
            children: weightOptions.map((weight) {
              return Center(
                child: Text(
                  '$weight kg',
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
