import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/product_recommendations_service.dart';
import 'package:bodido/core/services/user_service.dart';

class ProductRecommendationsState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final String? error;

  const ProductRecommendationsState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  ProductRecommendationsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? items,
    String? error,
    bool clearError = false,
  }) {
    return ProductRecommendationsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductRecommendationsViewModel
    extends StateNotifier<ProductRecommendationsState> {
  ProductRecommendationsViewModel()
      : super(const ProductRecommendationsState());

  Future<void> load(Ref ref, {int limit = 50}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userId = ref.read(userServiceProvider).userId;
      final svc = ref.read(productRecommendationsServiceProvider);
      final items = await svc.listByUserId(userId, limit: limit);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final productRecommendationsViewModelProvider = StateNotifierProvider
    .autoDispose<ProductRecommendationsViewModel, ProductRecommendationsState>(
  (ref) {
    final vm = ProductRecommendationsViewModel();
    Future.microtask(() => vm.load(ref));
    return vm;
  },
);
