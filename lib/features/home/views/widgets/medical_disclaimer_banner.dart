import 'package:bodido/common_libs.dart';

/// Reusable banner that shows a general health/medical disclaimer.
///
/// Used in places where the app presents wellness or health-related insights
/// (e.g. body simulator snapshot, AI explanations, etc.).
class MedicalDisclaimerBanner extends StatelessWidget {
  const MedicalDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all($styles.insets.sm),
      decoration: BoxDecoration(
        color: $styles.colors.backgroundDark,
        borderRadius: BorderRadius.circular($styles.corners.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '건강 정보 안내',
            style: $styles.text.bodyBold,
          ),
          SizedBox(height: $styles.insets.xxs),
          Text(
            '이 보고서는 일반적인 웰니스/건강 정보만을 제공하며, 질병의 진단, 치료 또는 '
            '전문적인 의학적 조언을 제공하지 않습니다. 건강 상태에 대한 우려가 있을 경우 '
            '반드시 의사 등 의료 전문가와 상담하십시오.',
            style: $styles.text.caption.copyWith(
              color: $styles.colors.body,
            ),
          ),
          SizedBox(height: $styles.insets.xs),
          Text(
            '더 자세한 건강 정보는 다음과 같은 공신력 있는 기관의 자료를 참고하실 수 있습니다:\n'
            '• World Health Organization (WHO)\n'
            '• American Heart Association (AHA)\n',
            style: $styles.text.caption.copyWith(
              color: $styles.colors.body,
            ),
          ),
        ],
      ),
    );
  }
}


