import 'package:regene/common_libs.dart';

class TappableScore extends StatefulWidget {
  const TappableScore({super.key, required this.onTap});
  final VoidCallback onTap;

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
              const TextSpan(text: '89'),
              TextSpan(
                text: '.2',
                style: $styles.text.number.copyWith(
                  color: $styles.colors.accent1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -10,
                  fontSize: $styles.text.number.fontSize! * 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
