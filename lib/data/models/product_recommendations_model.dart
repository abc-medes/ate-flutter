import 'dart:convert';

class ProductRecommendationItem {
  final String category;
  final int priority;
  final List<String> keyBenefits;
  final String productName;
  final String whyItHelps;
  final String? affiliateUrl;
  final List<String> searchKeywords;
  final String? additionalNotes;
  final String? approxPriceRange;
  final List<String> recommendedUseCases;
  final String? bindingKey;

  ProductRecommendationItem({
    required this.category,
    required this.priority,
    required this.keyBenefits,
    required this.productName,
    required this.whyItHelps,
    this.affiliateUrl,
    required this.searchKeywords,
    this.additionalNotes,
    this.approxPriceRange,
    required this.recommendedUseCases,
    this.bindingKey,
  });

  factory ProductRecommendationItem.fromJson(Map<String, dynamic> json) {
    List<String> _toStringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const <String>[];
    }

    return ProductRecommendationItem(
      category: json['category']?.toString() ?? '',
      priority: int.tryParse(json['priority']?.toString() ?? '') ?? 0,
      keyBenefits: _toStringList(json['key_benefits']),
      productName: json['product_name']?.toString() ?? '',
      whyItHelps: json['why_it_helps']?.toString() ?? '',
      affiliateUrl: json['affiliate_url']?.toString(),
      searchKeywords: _toStringList(json['search_keywords']),
      additionalNotes: json['additional_notes']?.toString(),
      approxPriceRange: json['approx_price_range']?.toString(),
      recommendedUseCases: _toStringList(json['recommended_use_cases']),
      bindingKey: json['binding_key']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'priority': priority,
      'key_benefits': keyBenefits,
      'product_name': productName,
      'why_it_helps': whyItHelps,
      if (affiliateUrl != null) 'affiliate_url': affiliateUrl,
      'search_keywords': searchKeywords,
      if (additionalNotes != null) 'additional_notes': additionalNotes,
      if (approxPriceRange != null) 'approx_price_range': approxPriceRange,
      'recommended_use_cases': recommendedUseCases,
      if (bindingKey != null) 'binding_key': bindingKey,
    };
  }
}

class ProductRecommendationsRow {
  final int? idx;
  final String id;
  final String userId;
  final List<ProductRecommendationItem> recommendations;
  final Map<String, dynamic>? shoppingContextSnapshot;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductRecommendationsRow({
    this.idx,
    required this.id,
    required this.userId,
    required this.recommendations,
    this.shoppingContextSnapshot,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductRecommendationsRow.fromJson(Map<String, dynamic> json) {
    dynamic _ensureDecoded(dynamic v) {
      if (v is String) {
        try {
          return jsonDecode(v);
        } catch (_) {
          return null;
        }
      }
      return v;
    }

    List<ProductRecommendationItem> _parseRecommendations(dynamic v) {
      final decoded = _ensureDecoded(v);
      if (decoded is List) {
        return decoded
            .map((e) => e is Map<String, dynamic>
                ? ProductRecommendationItem.fromJson(e)
                : ProductRecommendationItem.fromJson(
                    Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return const <ProductRecommendationItem>[];
    }

    Map<String, dynamic>? _parseMap(dynamic v) {
      final decoded = _ensureDecoded(v);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    }

    DateTime _parseDate(dynamic v) {
      final s = v?.toString();
      final dt = s == null ? null : DateTime.tryParse(s);
      return dt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return ProductRecommendationsRow(
      idx: json['idx'] is int
          ? json['idx'] as int
          : int.tryParse('${json['idx']}'),
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      recommendations: _parseRecommendations(json['recommendations']),
      shoppingContextSnapshot: _parseMap(json['shopping_context_snapshot']),
      metadata: _parseMap(json['metadata']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idx != null) 'idx': idx,
      'id': id,
      'user_id': userId,
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
      if (shoppingContextSnapshot != null)
        'shopping_context_snapshot': shoppingContextSnapshot,
      if (metadata != null) 'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
