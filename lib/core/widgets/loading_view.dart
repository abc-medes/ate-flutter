import 'package:regene/common_libs.dart';
import 'dart:math' as math;

// Track whether overlay is currently shown
bool _isOverlayShown = false;
OverlayEntry? _currentOverlayEntry;

class LoadingScreen extends StatefulWidget {
  final String? message;
  final bool showLogo;

  const LoadingScreen({
    super.key,
    this.message,
    this.showLogo = true,
  });

  static void show(BuildContext context, {String? message}) {
    try {
      // If already showing, just update the message
      if (_isOverlayShown && _currentOverlayEntry != null) {
        print('Loading screen already shown, updating message: $message');
        return;
      }

      dismiss(context);

      if (!context.mounted) return;

      final overlayEntry = OverlayEntry(
        builder: (context) => LoadingScreen(
          message: message,
        ),
      );

      _currentOverlayEntry = overlayEntry;
      _isOverlayShown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (context.mounted) {
            Overlay.of(context).insert(overlayEntry);
            print('Loading screen shown: $message');
          }
        } catch (e) {
          print('Error showing loading screen in post-frame: $e');
        }
      });
    } catch (e) {
      print('Error preparing loading screen: $e');
    }
  }

  static void dismiss(BuildContext context) {
    if (!_isOverlayShown || _currentOverlayEntry == null) return;

    try {
      _currentOverlayEntry?.remove();
      print('Loading screen dismissed');
    } catch (e) {
      print('Error removing loading overlay: $e');
    } finally {
      _currentOverlayEntry = null;
      _isOverlayShown = false;
    }
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
        color: Colors.black.withOpacity(0.1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // if (widget.showLogo) ...[
              //   _buildAnimatedLogo(),
              //   const SizedBox(height: 32),
              // ],
              _buildLoadingDots(),
              // if (widget.message != null) ...[
              //   const SizedBox(height: 24),
              //   Text(
              //     widget.message!,
              //     style: TextStyle(
              //       color: AppColors.surface,
              //       fontSize: 16,
              //       fontWeight: FontWeight.w500,
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ],
            ],
          ),
        ),
      ),
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
