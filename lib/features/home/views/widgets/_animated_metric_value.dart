import 'package:flutter/material.dart';

/// Displays a number that briefly flashes green or red whenever it changes.
/// • If [isIncreaseGood] is true  → an increase flashes green, decrease red.
/// • If [isIncreaseGood] is false → an increase flashes red,   decrease green.
/// Provide [suffix] for units (e.g. " bpm", "%").
class AnimatedMetricValue extends StatefulWidget {
  final double value;
  final bool isIncreaseGood;
  final String suffix;

  const AnimatedMetricValue({
    super.key,
    required this.value,
    this.isIncreaseGood = true,
    this.suffix = '',
  });

  @override
  State<AnimatedMetricValue> createState() => _AnimatedMetricValueState();
}

class _AnimatedMetricValueState extends State<AnimatedMetricValue>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _textColor;
  double? _prev;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _textColor = AlwaysStoppedAnimation<Color?>(null);
    _prev = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedMetricValue oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != _prev) {
      final wentUp = widget.value > (_prev ?? widget.value);
      final good = widget.isIncreaseGood ? wentUp : !wentUp;
      final flash = good ? Colors.greenAccent : Colors.redAccent;

      final base = DefaultTextStyle.of(context).style.color ?? Colors.black;
      _textColor = ColorTween(begin: flash, end: base).animate(_controller);
      _controller.forward(from: 0);
      _prev = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = DefaultTextStyle.of(context).style.color ?? Colors.black;
    return AnimatedBuilder(
      animation: _textColor,
      builder: (_, __) => Container(
        alignment: Alignment.centerRight,
        child: Text(
          '${_format(widget.value)}${widget.suffix}',
          style: TextStyle(
              color: _textColor.value ?? baseColor,
              fontFeatures: [FontFeature.tabularFigures()]),
        ),
      ),
    );
  }

  String _format(double v) {
    // e.g. 82.000 -> "82", 82.126 -> "82.1" (precision = 1)
    final s = v.toStringAsFixed(2);
    return s.endsWith('.' + '0' * 2) ? s.split('.').first : s;
  }
}
