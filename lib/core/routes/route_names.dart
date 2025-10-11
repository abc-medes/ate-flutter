class RouteNames {
  // Auth Routes
  static const login = '/auth/login';
  static const emailLoginInput = '/auth/email-login-input';
  static const signup = '/auth/signup';
  static const onboarding = '/auth/onboarding';
  static const checkingEmail = '/auth/checking-email';
  static const resetPassword = '/auth/reset-password';

  static const bodySimulator = '/body-simulator';

  // Main Routes
  static const home = '/';
  // static const debug = '/debug';
  // static const home = '/home';
  static const profile = '/profile';
  static const settings = '/settings';
  static const changePassword = '/settings/change-password';
  static const chatHistory = '/chat-history';
  static const String chat = '/chat-history/:sessionId';

  // Cannot be instantiated
  RouteNames._();
}
