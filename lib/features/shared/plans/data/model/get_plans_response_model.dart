class SubscriptionPlansResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<SubscriptionPlanModel> results;

  SubscriptionPlansResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlansResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}

class SubscriptionPlanModel {
  final int id;
  final String planType;
  final String tier;
  final String name;
  final String price;
  final String currency;
  final int? bookingLimit;
  final bool isActive;
  final List<SubscriptionFeatureModel> features;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.planType,
    required this.tier,
    required this.name,
    required this.price,
    required this.currency,
    required this.bookingLimit,
    required this.isActive,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as int,
      planType: json['plan_type'] as String,
      tier: json['tier'] as String,
      name: json['name'] as String,
      price: json['price'] as String,
      currency: json['currency'] as String,
      bookingLimit: json['booking_limit'] as int?,
      isActive: json['is_active'] as bool,
      features: (json['features'] as List<dynamic>)
          .map(
            (e) => SubscriptionFeatureModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_type': planType,
      'tier': tier,
      'name': name,
      'price': price,
      'currency': currency,
      'booking_limit': bookingLimit,
      'is_active': isActive,
      'features': features.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isStudentPlan => planType == 'student';
  bool get isEnterprisePlan => planType == 'enterprise';
}

class SubscriptionFeatureModel {
  final int id;
  final String featureKey;
  final String featureKeyDisplay;
  final int? limit;

  SubscriptionFeatureModel({
    required this.id,
    required this.featureKey,
    required this.featureKeyDisplay,
    this.limit,
  });

  factory SubscriptionFeatureModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeatureModel(
      id: json['id'] as int,
      featureKey: json['feature_key'] ?? '',
      featureKeyDisplay: json['feature_key_display'] ?? '',
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feature_key': featureKey,
      'feature_key_display': featureKeyDisplay,
      'limit': limit,
    };
  }
}

class PlanDiscountsModel {
  final double threeMonthsDiscount;
  final double yearlyDiscount;

  PlanDiscountsModel({
    required this.threeMonthsDiscount,
    required this.yearlyDiscount,
  });

  factory PlanDiscountsModel.fromJson(Map<String, dynamic> json) {
    return PlanDiscountsModel(
      threeMonthsDiscount:
          (json['three_months_discount'] as num?)?.toDouble() ?? 0.0,
      yearlyDiscount: (json['yearly_discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double getDiscountForDuration(String duration) {
    if (duration == 'biannual' ||
        duration == 'three_months' ||
        duration == 'six_months') {
      return threeMonthsDiscount;
    } else if (duration == 'yearly') {
      return yearlyDiscount;
    }
    return 0.0;
  }
}
