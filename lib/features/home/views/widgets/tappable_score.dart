import 'package:bodido/common_libs.dart';

class TappableScore extends StatefulWidget {
  const TappableScore({super.key, required this.score, required this.onTap});
  final VoidCallback onTap;
  final double score;

  @override
  State<TappableScore> createState() => TappableScoreState();
}

class TappableScoreState extends State<TappableScore> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    // We call the onTap callback on tap up to ensure the animation completes
    widget.onTap();
    // A slight delay before scaling back up to make the tap feel more deliberate.
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.95 : 1.0;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: RichText(
          text: TextSpan(
            style: $styles.text.number.copyWith(
                color: $styles.colors.accent1,
                fontWeight: FontWeight.w900,
                letterSpacing: -10),
            children: <TextSpan>[
              // Split score into integer and fractional parts for styling
              ..._buildScoreSpans(widget.score),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns two TextSpan: integer part and fractional part (with dot)
  List<TextSpan> _buildScoreSpans(double value) {
    // Keep one decimal place
    final fixed = value.toStringAsFixed(1);
    final parts = fixed.split('.');
    final intPart = parts.first;
    final fracPart = '.${parts.last}';

    return [
      TextSpan(text: intPart),
      TextSpan(
        text: fracPart,
        style: $styles.text.number.copyWith(
          color: $styles.colors.accent1,
          fontWeight: FontWeight.w900,
          letterSpacing: -5,
          fontSize: $styles.text.number.fontSize! * 0.5,
        ),
      ),
    ];
  }
}
