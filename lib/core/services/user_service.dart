import 'package:ate_project/data/models/health_model.dart';
import 'package:ate_project/data/repositories/health_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {
  final _healthRepository = healthRepository;
  List<BasicUserData> _missingBasicUserData = [];
  bool _initialized = false;

  List<BasicUserData> get missingBasicUserData => _missingBasicUserData;
  bool get isBasicHealthDataComplete => _missingBasicUserData.isEmpty;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    await refreshBasicHealthData();
    _initialized = true;
  }

  Future<void> refreshBasicHealthData() async {
    _missingBasicUserData = await _healthRepository.getMissingBasicUserData();
  }

  Future<bool> isFieldComplete(BasicUserData field) async {
    return await _healthRepository.isBasicUserDataSaved(field);
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final service = UserService();
  service.initialize();
  return service;
});
