import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HeightPickerWidget extends StatelessWidget {
  final int selectedHeight;
  final Function(int) onHeightChanged;

  const HeightPickerWidget({
    Key? key,
    required this.selectedHeight,
    required this.onHeightChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heightOptions =
        List.generate(121, (index) => index + 120); // 120-240 cm

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(
              initialItem: heightOptions.indexOf(selectedHeight),
            ),
            onSelectedItemChanged: (index) {
              onHeightChanged(heightOptions[index]);
            },
            children: heightOptions.map((height) {
              return Center(
                child: Text(
                  '$height cm',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
