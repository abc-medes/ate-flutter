import 'package:regene/common_libs.dart';

class BodyScoreHeader extends ConsumerWidget {
  final int bodyScore;
  final int reliabilityScore;
  const BodyScoreHeader({
    super.key,
    required this.bodyScore,
    required this.reliabilityScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all($styles.insets.md),
      child: Card(
        color: $styles.colors.backgroundDark,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular($styles.insets.xl),
        ),
        child: CustomPaint(
          painter: BorderPainter(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '90',
                      style: $styles.text.number.copyWith(
                        fontSize: 120,
                        letterSpacing: -10,
                        color: $styles.colors.accent1,
                      ),
                    ),
                  ],
                ),
                // Text('Reliability Score', style: $styles.text.h1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(12));

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DNAPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final connectorPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 1.5;

    const waveAmplitude = 20.0;
    const waveFrequency = 2.0;
    const steps = 100;

    for (int i = 0; i < steps; i++) {
      final t = i / steps;
      final x = t * size.width;
      final y1 = size.height / 2 + waveAmplitude * sin(waveFrequency * pi * t);
      final y2 = size.height / 2 - waveAmplitude * sin(waveFrequency * pi * t);

      // 나선 곡선의 점
      canvas.drawCircle(Offset(x, y1), 2, paint1);
      canvas.drawCircle(Offset(x, y2), 2, paint2);

      // 중간 염기쌍 연결선
      if (i % 5 == 0) {
        canvas.drawLine(Offset(x, y1), Offset(x, y2), connectorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
