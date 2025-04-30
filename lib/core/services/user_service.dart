import 'package:ate_project/data/models/health_model.dart';
import 'package:ate_project/data/repositories/health_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {
  final _healthRepository = HealthRepository();
  late final bool _isBasicHealthDataComplete;

  bool get isBasicHealthDataComplete => _isBasicHealthDataComplete;

  UserService() {
    hasBasicHealthDataComplete();
  }

  Future<List<BasicUserData>> hasBasicHealthDataComplete() async {
    final missingUserInputData =
        await _healthRepository.getMissingBasicUserData();
    _isBasicHealthDataComplete = missingUserInputData.isEmpty;
    return missingUserInputData;
  }
}

final userServiceProvider = Provider<UserService>((ref) => UserService());
