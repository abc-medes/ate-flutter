import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ate_project/data/models/health_model.dart';

class HealthRepository {
  static const String _healthDataKey = 'health_data';

  Future<bool> isUserInputFieldSaved(UserInputField field) async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_healthDataKey)) {
      return false;
    }

    try {
      final jsonString = prefs.getString(_healthDataKey);
      if (jsonString == null) return false;

      final healthData = jsonDecode(jsonString);

      if (healthData == null || !healthData.containsKey('user_input_data')) {
        return false;
      }

      final userInputData = healthData['user_input_data'];

      final tempData = UserInputData();
      tempData.setField(field, true);

      final jsonMap = tempData.toJson();

      return jsonMap.keys.any((key) => userInputData.containsKey(key));
    } catch (e) {
      return false;
    }
  }
}
