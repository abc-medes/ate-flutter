import 'package:ate_project/data/models/user_model.dart';
import 'package:ate_project/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  User? user;
  bool isLoading = false;

  HomeViewModel(this._userRepository);

  Future<void> loadUser(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _userRepository.fetchUser(userId);
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
