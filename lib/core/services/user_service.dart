import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});
