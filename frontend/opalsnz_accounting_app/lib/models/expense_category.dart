class ExpenseCategory {
  ExpenseCategory({
    required this.id,
    required this.name,
    required this.defaultClaimPercent,
    required this.hasGst,
    required this.isActive,
  });

  final int id;
  final String name;
  final double defaultClaimPercent;
  final bool hasGst;
  final bool isActive;

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) =>
      ExpenseCategory(
        id: json['id'] as int,
        name: json['name'] as String,
        defaultClaimPercent: (json['defaultClaimPercent'] as num).toDouble(),
        hasGst: json['hasGst'] as bool,
        isActive: json['isActive'] as bool,
      );

  Map<String, dynamic> toRequestJson() => {
    'name': name,
    'defaultClaimPercent': defaultClaimPercent,
    'hasGst': hasGst,
    'isActive': isActive,
  };
}
