import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/product/product_link_bindings_service.dart';
import 'package:bodido/core/services/product/product_recommendations_service.dart';
import 'package:bodido/core/services/user_service.dart';
import 'package:bodido/data/models/product_recommendations_model.dart';

class ProductRecommendationsState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final String? error;
  final Map<String, Map<String, dynamic>> linksByBindingId;

  const ProductRecommendationsState({
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.linksByBindingId = const {},
  });

  ProductRecommendationsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? items,
    String? error,
    bool clearError = false,
    Map<String, Map<String, dynamic>>? linksByBindingId,
  }) {
    return ProductRecommendationsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      linksByBindingId: linksByBindingId ?? this.linksByBindingId,
    );
  }
}

class ProductRecommendationsViewModel
    extends StateNotifier<ProductRecommendationsState> {
  ProductRecommendationsViewModel()
      : super(const ProductRecommendationsState());

  Future<void> load(Ref ref) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userId = ref.read(userServiceProvider).userId;
      final svc = ref.read(productRecommendationsServiceProvider);
      final row = await svc.getByUserIdSingle(userId); // unique row per user
      final items =
          row == null ? <Map<String, dynamic>>[] : <Map<String, dynamic>>[row];

      final parsed = items
          .map((r) =>
              ProductRecommendationsRow.fromJson(Map<String, dynamic>.from(r)))
          .toList();
      final recs = parsed.expand((r) => r.recommendations).toList();

      final ids = <String>{
        for (final it in recs)
          if ((it.bindingId ?? '').isNotEmpty) it.bindingId!,
      };

      Map<String, Map<String, dynamic>> linksById = {};
      if (ids.isNotEmpty) {
        final linkSvc = ref.read(productLinkBindingsServiceProvider);
        final links = await linkSvc.getByIds(ids.toList());
        linksById = {
          for (final r in links)
            (r['id']?.toString() ?? ''): Map<String, dynamic>.from(r),
        }..removeWhere((k, _) => k.isEmpty);
      }

      state = state.copyWith(
        items: items,
        linksByBindingId: linksById, // NEW
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
