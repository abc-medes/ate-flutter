import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder for home. Extend state and VM as you renew the app.
class HomeViewState {
  const HomeViewState();
}

class HomeViewModel extends StateNotifier<HomeViewState> {
  HomeViewModel() : super(const HomeViewState());
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewState>(
  (ref) => HomeViewModel(),
);

/// Kept so widgets that reference it (e.g. ChatHelper) still compile.
enum ChatHelperType { ai, alerts, waitlist, system, context }
