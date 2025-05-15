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
  bool _isErasing = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _currentText = widget.texts[_currentIndex];

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
      if (_textPosition < _currentText.length) {
        setState(() {
          _displayText = _currentText.substring(0, _textPosition + 1);
          _textPosition++;
        });

        if (widget.enableVibration) {
          HapticFeedback.lightImpact();
        }

        Future.delayed(widget.typingSpeed, _animateText);
      } else {
        setState(() {
          _isTyping = false;
          _isErasing = true;
        });

        Future.delayed(widget.pauseBetween, _animateText);
      }
    } else if (_isErasing) {
      if (_textPosition > 0) {
        setState(() {
          _textPosition--;
          _displayText = _currentText.substring(0, _textPosition);
        });

        Future.delayed(widget.typingSpeed ~/ 2, _animateText); // faster erase
      } else {
        setState(() {
          _isErasing = false;
          _isPaused = true;
        });

        Future.delayed(const Duration(milliseconds: 300), _animateText);
      }
    } else if (_isPaused) {
      if (!widget.loop && _currentIndex == widget.texts.length - 1) {
        setState(() {
          _isCompleted = true;
        });
        return;
      }

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(text: _displayText, style: widget.textStyle),
          const WidgetSpan(
            child: SizedBox(
              width: 5,
              height: 10,
            ),
          ),
          WidgetSpan(
            child: SvgPicture.string(
              svgString,
              width: widget.textStyle.fontSize,
              height: widget.textStyle.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
