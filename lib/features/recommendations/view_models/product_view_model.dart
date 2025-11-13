import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/product/product_link_bindings_service.dart';
import 'package:bodido/core/services/product/product_recommendations_service.dart';
import 'package:bodido/core/services/user_service.dart';
import 'package:bodido/data/models/product_recommendations_model.dart';

class ProductRecommendationsState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final String? error;
  final Map<String, Map<String, dynamic>> linksByBindingKey;

  const ProductRecommendationsState({
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.linksByBindingKey = const {},
  });

  ProductRecommendationsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? items,
    String? error,
    bool clearError = false,
    Map<String, Map<String, dynamic>>? linksByTitle,
    Map<String, Map<String, dynamic>>? linksByBindingKey,
  }) {
    return ProductRecommendationsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      linksByBindingKey: linksByTitle ?? this.linksByBindingKey,
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

      final rows = items
          .map((row) => ProductRecommendationsRow.fromJson(
                Map<String, dynamic>.from(row),
              ))
          .toList();
      final all = rows.expand((r) => r.recommendations).toList();

      final keys = <String>{
        for (final it in all)
          if ((it.bindingKey ?? '').isNotEmpty) it.bindingKey!,
      };

      Map<String, Map<String, dynamic>> linkMap = {};
      if (keys.isNotEmpty) {
        final linkSvc = ref.read(productLinkBindingsServiceProvider);
        final links = await linkSvc.getByBindingKeys(keys.toList());
        linkMap = {
          for (final r in links)
            (r['binding_key']?.toString() ?? ''): Map<String, dynamic>.from(r),
        }..removeWhere((k, _) => k.isEmpty);
      }

      state = state.copyWith(
        items: items,
        linksByBindingKey: linkMap,
        isLoading: false,
      );
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
