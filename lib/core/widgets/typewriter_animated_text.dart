import 'package:flutter/material.dart';

class TypewriterAnimatedText extends StatefulWidget {
  final List<String> texts;
  final TextStyle textStyle;
  final Duration typingSpeed;
  final Duration pauseBetween;
  final bool loop;

  const TypewriterAnimatedText(
    this.texts, {
    super.key,
    required this.textStyle,
    this.typingSpeed = const Duration(milliseconds: 50),
    this.pauseBetween = const Duration(milliseconds: 1500),
    this.loop = true,
  });

  @override
  State<TypewriterAnimatedText> createState() => _TypewriterAnimatedTextState();
}

class _TypewriterAnimatedTextState extends State<TypewriterAnimatedText> {
  late String _currentText;
  late int _currentIndex;
  String _displayText = "";
  int _textPosition = 0;
  bool _isTyping = true;
  bool _isPaused = false;
  bool _isCompleted = false;

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
        Future.delayed(widget.typingSpeed, _animateText);
      } else {
        setState(() {
          _isTyping = false;
          _isPaused = true;
        });
        Future.delayed(widget.pauseBetween, _animateText);
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
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.textStyle.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
