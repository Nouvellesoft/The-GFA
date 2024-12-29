class PlanPricing {
  final double standardMonthly;
  final double advancedMonthly;
  final double standardAnnual;
  final double advancedAnnual;
  final double standardAnnualDiscount;
  final double advancedAnnualDiscount;

  PlanPricing({
    required this.standardMonthly,
    required this.advancedMonthly,
    required this.standardAnnual,
    required this.advancedAnnual,
    required this.standardAnnualDiscount,
    required this.advancedAnnualDiscount,
  });

  factory PlanPricing.fromRTDB(Map data) {
    return PlanPricing(
      standardMonthly: (data['standardMonthly'] ?? 11).toDouble(),
      advancedMonthly: (data['advancedMonthly'] ?? 22).toDouble(),
      standardAnnual: (data['standardAnnual'] ?? 332).toDouble(),
      advancedAnnual: (data['advancedAnnual'] ?? 554).toDouble(),
      standardAnnualDiscount: (data['standardAnnualDiscount'] ?? 60).toDouble(),
      advancedAnnualDiscount: (data['advancedAnnualDiscount'] ?? 100).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'standardMonthly': standardMonthly,
      'advancedMonthly': advancedMonthly,
      'standardAnnual': standardAnnual,
      'advancedAnnual': advancedAnnual,
      'standardAnnualDiscount': standardAnnualDiscount,
      'advancedAnnualDiscount': advancedAnnualDiscount,
    };
  }
}
