import 'package:flutter/material.dart';

class RainbowBorderEffect extends StatefulWidget {
  final Widget child;

  const RainbowBorderEffect({
    super.key,
    required this.child,
  });

  @override
  State<RainbowBorderEffect> createState() => _RainbowBorderEffectState();
}

class _RainbowBorderEffectState extends State<RainbowBorderEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.red,
              ],
              stops: const [0.0, 0.1667, 0.3333, 0.5, 0.6667, 0.8333, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_controller.value * 2 * 3.14159),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0), // Border thickness
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
