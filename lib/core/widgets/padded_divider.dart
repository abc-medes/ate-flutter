import 'package:flutter/material.dart';

class PaddedDivider extends StatelessWidget {
  final Color? color;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final double topPadding;
  final double bottomPadding;

  const PaddedDivider({
    super.key,
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
    this.topPadding = 0,
    this.bottomPadding = 0,
  });

  /// Creates a divider with medium padding above and below (24px)
  const PaddedDivider.medium({
    super.key,
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
  })  : topPadding = 24.0,
        bottomPadding = 24.0;

  /// Creates a divider with small padding above and below (16px)
  const PaddedDivider.small({
    super.key,
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
  })  : topPadding = 16.0,
        bottomPadding = 16.0;

  /// Creates a divider with large padding above and below (32px)
  const PaddedDivider.large({
    super.key,
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
  })  : topPadding = 32.0,
        bottomPadding = 32.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (topPadding > 0) SizedBox(height: topPadding),
        Divider(
          color: color,
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
        ),
        if (bottomPadding > 0) SizedBox(height: bottomPadding),
      ],
    );
  }
}
