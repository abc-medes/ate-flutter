import 'dart:async';
import 'package:flutter/material.dart';

class LiveTypewriter extends StatefulWidget {
  const LiveTypewriter({
    super.key,
    required this.lines,
    required this.style,
    this.charDelay = const Duration(milliseconds: 40),
    this.linePause = const Duration(milliseconds: 600),
    this.expectedLineCount,
    this.onComplete,
  });

  /// List you keep appending to; the widget will automatically type
  /// new lines as they appear.
  final List<String> lines;

  final TextStyle style;
  final Duration charDelay;
  final Duration linePause;
  final int? expectedLineCount;
  final VoidCallback? onComplete;

  @override
  State<LiveTypewriter> createState() => _LiveTypewriterState();
}

class _LiveTypewriterState extends State<LiveTypewriter> {
  final StringBuffer _buffer = StringBuffer();
  int _charIndex = 0;
  int _lineIndex = 0;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant LiveTypewriter old) {
    super.didUpdateWidget(old);
    if (widget.lines.length > old.lines.length) _completed = false;

    if (_timer == null && _lineIndex < widget.lines.length) _start();
  }

  void _start() => _timer = Timer(widget.charDelay, _tick);

  void _tick() {
    if (!mounted) return;

    final int target = widget.expectedLineCount ?? widget.lines.length;

    if (_lineIndex >= target) {
      _timer = null;
      if (!_completed) {
        _completed = true;
        widget.onComplete?.call();
      }
      return;
    }

    if (_lineIndex >= widget.lines.length) {
      _timer = Timer(widget.linePause, _tick);
      return;
    }

    final currentLine = widget.lines[_lineIndex];

    if (_charIndex < currentLine.length) {
      _buffer.write(currentLine[_charIndex]);
      _charIndex++;
      setState(() {});
      _timer = Timer(widget.charDelay, _tick);
    } else {
      _buffer.writeln();
      _lineIndex++;
      _charIndex = 0;
      setState(() {});
      _timer = Timer(widget.linePause, _tick);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _buffer.toString(),
      textAlign: TextAlign.center,
      style: widget.style,
    );
  }
}
