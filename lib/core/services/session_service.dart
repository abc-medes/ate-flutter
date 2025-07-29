import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final sessionIdProvider = StateProvider<String>((ref) => Uuid().v4());
