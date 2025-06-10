import 'dart:ui';

import 'package:flutter/material.dart';

class HeartHealthScreen extends StatefulWidget {
  const HeartHealthScreen({super.key});

  @override
  State<HeartHealthScreen> createState() => _HeartHealthScreenState();
}

class _HeartHealthScreenState extends State<HeartHealthScreen> {
  // 현재 심장 건강 데이터 (예시 값)
  double bloodSugar = 85.0; // 혈당 (mg/dL)
  double bloodPressureSystolic = 115.0; // 수축기 혈압
  double bloodPressureDiastolic = 75.0; // 이완기 혈압 (편의상 분리)
  double heartRate = 65.0; // 심박수 (bpm)
  double hrv = 65.0; // 심박변이도 (ms, 예시)

  // ----------------------------------------------------------------------
  // 1. 심장 건강 점수 계산 로직
  // ----------------------------------------------------------------------
  int _calculateHeartScore() {
    int totalScore = 0;

    // 혈당 점수 (최대 25점)
    if (bloodSugar >= 70 && bloodSugar <= 100) {
      totalScore += 25; // 최적
    } else if ((bloodSugar > 100 && bloodSugar <= 125) ||
        (bloodSugar >= 60 && bloodSugar < 70)) {
      totalScore += 15; // 주의
    } else {
      totalScore += 5; // 위험
    }

    // 혈압 점수 (최대 25점)
    // 수축기: 90-120, 이완기: 60-80
    if ((bloodPressureSystolic >= 90 && bloodPressureSystolic <= 120) &&
        (bloodPressureDiastolic >= 60 && bloodPressureDiastolic <= 80)) {
      totalScore += 25; // 최적
    } else if (((bloodPressureSystolic > 120 && bloodPressureSystolic <= 139) ||
            (bloodPressureSystolic >= 80 && bloodPressureSystolic < 90)) ||
        ((bloodPressureDiastolic > 80 && bloodPressureDiastolic <= 89) ||
            (bloodPressureDiastolic >= 50 && bloodPressureDiastolic < 60))) {
      totalScore += 15; // 주의
    } else {
      totalScore += 5; // 위험
    }

    // 심박수 점수 (최대 25점)
    if (heartRate >= 60 && heartRate <= 100) {
      totalScore += 25; // 최적
    } else if ((heartRate > 100 && heartRate <= 120) ||
        (heartRate >= 50 && heartRate < 60)) {
      totalScore += 15; // 주의
    } else {
      totalScore += 5; // 위험
    }

    // HRV (심박변이도) 점수 (최대 25점)
    if (hrv >= 50) {
      totalScore += 25; // 최적
    } else if (hrv >= 20 && hrv < 50) {
      totalScore += 15; // 주의
    } else {
      totalScore += 5; // 위험
    }

    // 점수는 0-100 범위로 보장 (최소 20점, 최대 100점)
    return totalScore;
  }

  // ----------------------------------------------------------------------
  // 2. 점수에 따른 심장 색상 (회색 투명도) 결정 로직
  // ----------------------------------------------------------------------
  Color _getHeartColor() {
    int score = _calculateHeartScore();

    // 기본 심장 색상 (선명한 붉은색)
    const Color baseRed = Colors.red;

    // 점수에 따른 회색 투명도 계산
    double greyOpacity = 0.0; // 0.0 (완전 불투명) ~ 1.0 (완전 투명, 뒤에 가려진 색이 보임)
    // 여기서는 0.0이 건강한 상태, 1.0에 가까울수록 불건강 상태
    if (score >= 80) {
      greyOpacity = 0.0; // 매우 건강: 투명도 0% (기본 붉은색)
    } else if (score >= 60) {
      greyOpacity = 0.15; // 주의: 투명도 15% (옅은 생기 저하)
    } else if (score >= 40) {
      greyOpacity = 0.40; // 경고: 투명도 40% (뚜렷한 생기 저하)
    } else {
      greyOpacity = 0.75; // 위험: 투명도 75% (거의 회색에 가까움)
    }

    // 기본 붉은색 위에 회색 레이어를 덧씌우는 효과를 만듭니다.
    // 여기서는 기본 붉은색을 덜 선명하게 만들기 위해 `withOpacity`를 직접 적용합니다.
    // 만약 붉은색 위에 회색 컨테이너를 올릴 경우, Opacity 위젯을 사용해야 합니다.
    // 여기서는 붉은색 자체의 '생기'를 조절하는 방식으로 구현합니다.
    // 즉, greyOpacity가 높을수록 붉은색이 탁해지고 어두워지는 효과를 줍니다.
    // 이를 위해 Colors.red를 직접 사용하는 대신, HSV/HSL 또는 Color.fromRGBO를
    // 사용해서 명도나 채도를 조절하는 복합적인 방법이 더 정교할 수 있으나,
    // 간단한 예시를 위해 Colors.red의 투명도를 역으로 적용해 유사한 효과를 냅니다.

    // 혹은 명확하게 회색 오버레이를 만들려면 아래처럼 Opacity 위젯과 Stack을 사용합니다.
    // 지금은 Color.fromRGBO로 붉은색의 명도와 채도를 직접 조절하는 효과를 냅니다.
    // score가 낮을수록 RGB값이 작아지도록 하여 어둡고 탁하게 만듭니다.
    // R: 255 -> 0, G: 0 -> 0, B: 0 -> 0
    // 여기에 투명도는 A (alpha) 값으로 조절합니다.
    double normalizedScore = score / 100.0; // 0.0 ~ 1.0
    // 건강할수록 붉은색이 선명하도록, 불건강할수록 어두워지도록
    int redValue = (255 * normalizedScore).toInt().clamp(0, 255);
    int greenBlueValue = (60 * normalizedScore)
        .toInt()
        .clamp(0, 255); // 붉은색 계열 유지를 위해 G/B값은 낮게 시작

    // 여기서는 '회색 투명도' 개념을 좀 더 직접적으로 구현하기 위해,
    // 붉은색 위에 반투명한 회색 레이어가 덧씌워지는 느낌을 줍니다.
    // 실제 심장 색상은 기본 붉은색으로 유지하고, 그 위에 회색 오버레이를 렌더링하는 방식이 더 직관적입니다.
    // 여기서는 그냥 Color.fromRGBO를 사용해 '탁한 붉은색'을 직접 만듭니다.

    // 붉은색의 채도를 점수에 따라 조절
    // 점수가 높을수록 채도 높음 (선명한 붉은색), 낮을수록 채도 낮음 (회색빛 붉은색)
    final HSLColor baseHSL = HSLColor.fromColor(baseRed);
    final HSLColor finalHSL = baseHSL
        .withSaturation(
            normalizedScore * 0.8 + 0.2) // 채도 0.2 ~ 1.0 (너무 회색 되지 않도록)
        .withLightness(
            normalizedScore * 0.4 + 0.3); // 명도 0.3 ~ 0.7 (너무 어둡거나 밝지 않도록)

    return finalHSL.toColor();
  }

  @override
  Widget build(BuildContext context) {
    // 점수에 따른 심장 색상 결정
    Color heartColor = _getHeartColor();
    int currentScore = _calculateHeartScore();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Heart Health Score: $currentScore / 100',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        // 심장을 나타내는 위젯 (여기서는 원형 Container)
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: heartColor, // 계산된 심장 색상 적용
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: heartColor.withOpacity(0.6),
                blurRadius: 20.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '❤️',
              style:
                  TextStyle(fontSize: 80, color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ),
        const SizedBox(height: 40),
        // 슬라이더를 통해 각 지표 값 변경
        _buildDataSlider('Blood Sugar', bloodSugar, 50, 200, (value) {
          setState(() {
            bloodSugar = value;
          });
        }),
        _buildDataSlider(
            'Blood Pressure (Systolic)', bloodPressureSystolic, 80, 180,
            (value) {
          setState(() {
            bloodPressureSystolic = value;
          });
        }),
        _buildDataSlider(
            'Blood Pressure (Diastolic)', bloodPressureDiastolic, 40, 120,
            (value) {
          setState(() {
            bloodPressureDiastolic = value;
          });
        }),
        _buildDataSlider('Heart Rate', heartRate, 40, 150, (value) {
          setState(() {
            heartRate = value;
          });
        }),
        _buildDataSlider('HRV', hrv, 10, 100, (value) {
          setState(() {
            hrv = value;
          });
        }),
      ],
    );
  }

  // 데이터 슬라이더 위젯 생성 헬퍼 함수
  Widget _buildDataSlider(String label, double currentValue, double min,
      double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${currentValue.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16)),
          Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: ((max - min) / 5).round(), // 5단위로 조절 가능하도록
            label: currentValue.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
