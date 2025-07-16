import 'package:flutter/material.dart';
import 'package:regene/common_libs.dart'; // Or wherever your $styles comes from

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 64,
    this.iconSize = 28,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? $styles.colors.accent1,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? $styles.colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
