import 'package:bodiapp/core/constants/ai_messages.dart';

class AIMessageService {
  static String getAuthRequiredMessage() {
    return AIMessages.requireLogin;
  }

  static String getWelcomeMessage(String? userName) {
    return AIMessages.welcomeBack;
  }
}
