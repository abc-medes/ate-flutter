import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String svgString = '''
<svg width="8" height="20" viewBox="0 0 8 20" xmlns="http://www.w3.org/2000/svg">
            <rect width="8" height="20" rx="3" fill="#05804C"/>
          </svg>
''';

class TypewriterAnimatedText extends StatefulWidget {
  final List<String> texts;
  final TextStyle textStyle;
  final Duration typingSpeed;
  final Duration pauseBetween;
  final bool loop;
  final bool enableVibration;

  const TypewriterAnimatedText(
    this.texts, {
    super.key,
    required this.textStyle,
    this.typingSpeed = const Duration(milliseconds: 50),
    this.pauseBetween = const Duration(milliseconds: 1500),
    this.loop = true,
    this.enableVibration = true,
  });

  @override
  State<TypewriterAnimatedText> createState() => _TypewriterAnimatedTextState();
}

class _TypewriterAnimatedTextState extends State<TypewriterAnimatedText>
    with SingleTickerProviderStateMixin {
  late String _currentText;
  late int _currentIndex;
  String _displayText = "";
  int _textPosition = 0;
  bool _isTyping = true;
  bool _isPaused = false;
  bool _isCompleted = false;

  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _currentText = widget.texts[_currentIndex];

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Don't start blinking immediately
    _cursorController.value = 1.0;

    _startTyping();
  }

  void _startTyping() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _animateText();
    });
  }

  void _animateText() {
    if (!mounted) return;

    if (_isTyping) {
      // Stop cursor blinking while typing
      _cursorController.stop();
      _cursorController.value = 1.0;

      if (_textPosition < _currentText.length) {
        setState(() {
          _displayText = _currentText.substring(0, _textPosition + 1);
          _textPosition++;
        });

        if (widget.enableVibration) {
          HapticFeedback.lightImpact(); // Light vibration
        }

        Future.delayed(widget.typingSpeed, _animateText);
      } else {
        setState(() {
          _isTyping = false;
          _isPaused = true;
        });

        // Start cursor blinking when typing is done
        _cursorController.repeat(reverse: true);

        Future.delayed(widget.pauseBetween, _animateText);
      }
    } else if (_isPaused) {
      if (!widget.loop && _currentIndex == widget.texts.length - 1) {
        setState(() {
          _isCompleted = true;
        });
        return;
      }

      // Stop blinking when moving to the next text
      _cursorController.stop();
      _cursorController.value = 1.0;

      _currentIndex = (_currentIndex + 1) % widget.texts.length;
      _currentText = widget.texts[_currentIndex];
      setState(() {
        _textPosition = 0;
        _displayText = "";
        _isTyping = true;
        _isPaused = false;
      });
      _animateText();
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: _displayText,
            style: widget.textStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const WidgetSpan(
            child: SizedBox(
              width: 5,
              height: 10,
            ),
          ),
          WidgetSpan(
            child: AnimatedBuilder(
              animation: _cursorController,
              builder: (context, child) {
                return Opacity(
                  opacity: _cursorController.value,
                  child: SvgPicture.string(
                    svgString,
                    width: 22,
                    height: 22,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
