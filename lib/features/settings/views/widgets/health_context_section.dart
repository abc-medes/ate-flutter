import 'package:regene/common_libs.dart';
import 'package:regene/data/models/health_model.dart';
import 'package:regene/data/repositories/health_repository.dart';

class HealthContextSection extends StatelessWidget {
  const HealthContextSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HealthMetrics>(
      future: healthRepository.getExistingHealthMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Text(
              '건강 데이터를 불러올 수 없습니다.',
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.caption,
              ),
            ),
          );
        }

        final userInputData = snapshot.data!.userInputData;
        return Column(
          children: [
            if (userInputData.gender != null)
              _row(context, '성별', Icons.person,
                  userInputData.gender == 'male' ? '남성' : '여성'),
            if (userInputData.height != null)
              _row(context, '키', Icons.height,
                  '${userInputData.height!.toInt()}cm'),
            if (userInputData.weight != null)
              _row(context, '체중', Icons.monitor_weight,
                  '${userInputData.weight!.toInt()}kg'),
            if (userInputData.bodyType != null)
              _row(context, '체형', Icons.accessibility_new,
                  userInputData.bodyType!),
            if (userInputData.dateOfBirth != null)
              _row(
                context,
                '생년월일',
                Icons.cake,
                '${userInputData.dateOfBirth!.year}년 ${userInputData.dateOfBirth!.month}월 ${userInputData.dateOfBirth!.day}일',
              ),
          ],
        );
      },
    );
  }

  Widget _row(BuildContext context, String title, IconData icon, String value) {
    return ListTile(
      leading: Icon(icon, color: $styles.colors.accent1),
      title: Text(title, style: $styles.text.body),
      trailing: Text(
        value,
        style: $styles.text.bodySmall.copyWith(color: $styles.colors.accent1),
      ),
    );
  }
}
