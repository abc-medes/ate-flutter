import 'package:flutter/material.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'dart:math' as math;

// Global key to access the overlay state
final GlobalKey<_LoadingOverlayState> _overlayKey =
    GlobalKey<_LoadingOverlayState>();

class LoadingScreen extends StatefulWidget {
  final String? message;
  final bool showLogo;

  const LoadingScreen({
    Key? key,
    this.message,
    this.showLogo = true,
  }) : super(key: key);

  /// Show loading screen as an overlay (compatible with GoRouter)
  static void show(BuildContext context, {String? message}) {
    // Ensure we don't have existing overlay
    dismiss(context);

    // Create overlay entry
    final overlay = _LoadingOverlay(
      key: _overlayKey,
      message: message,
    );

    // Insert overlay
    Overlay.of(context).insert(overlay._overlayEntry);
  }

  /// Dismiss the loading screen overlay
  static void dismiss(BuildContext context) {
    _overlayKey.currentState?.dismiss();
  }

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

/// Overlay implementation for the loading screen
class _LoadingOverlay extends StatefulWidget {
  final String? message;
  final OverlayEntry _overlayEntry;

  _LoadingOverlay({
    required Key key,
    this.message,
  })  : _overlayEntry = OverlayEntry(
          builder: (context) => LoadingScreen(
            message: message,
          ),
        ),
        super(key: key);

  @override
  _LoadingOverlayState createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
  void dismiss() {
    try {
      widget._overlayEntry.remove();
    } catch (e) {
      print('Failed to remove overlay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showLogo) ...[
                _buildAnimatedLogo(),
                const SizedBox(height: 32),
              ],
              _buildLoadingIndicator(),
              if (widget.message != null) ...[
                const SizedBox(height: 24),
                Text(
                  widget.message!,
                  style: TextStyle(
                    color: AppColors.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + 0.1 * math.sin(2 * math.pi * _controller.value),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety,
              size: 64,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        _buildLoadingDots(),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final offset = _controller.value - delay;
            final opacity =
                math.sin((offset < 0 ? offset + 1 : offset) * math.pi).abs();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
