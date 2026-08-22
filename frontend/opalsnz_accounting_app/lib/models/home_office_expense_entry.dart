class HomeOfficeExpenseEntry {
  HomeOfficeExpenseEntry({
    required this.id,
    required this.expenseCategoryId,
    required this.expenseCategoryName,
    required this.entryDate,
    required this.grossAmount,
    required this.claimPercent,
    required this.hasGst,
    required this.claimableAmount,
    required this.claimableGst,
    this.notes,
  });

  final int id;
  final int expenseCategoryId;
  final String expenseCategoryName;
  final DateTime entryDate;
  final double grossAmount;
  final double claimPercent;
  final bool hasGst;
  final double claimableAmount;
  final double claimableGst;
  final String? notes;

  factory HomeOfficeExpenseEntry.fromJson(Map<String, dynamic> json) => HomeOfficeExpenseEntry(
        id: json['id'] as int,
        expenseCategoryId: json['expenseCategoryId'] as int,
        expenseCategoryName: json['expenseCategoryName'] as String,
        entryDate: DateTime.parse(json['entryDate'] as String),
        grossAmount: (json['grossAmount'] as num).toDouble(),
        claimPercent: (json['claimPercent'] as num).toDouble(),
        hasGst: json['hasGst'] as bool,
        claimableAmount: (json['claimableAmount'] as num).toDouble(),
        claimableGst: (json['claimableGst'] as num).toDouble(),
        notes: json['notes'] as String?,
      );
}

class HomeOfficeExpenseUpsertRequest {
  HomeOfficeExpenseUpsertRequest({
    required this.expenseCategoryId,
    required this.entryDate,
    required this.grossAmount,
    this.claimPercent,
    this.hasGst,
    this.notes,
  });

  final int expenseCategoryId;
  final DateTime entryDate;
  final double grossAmount;
  final double? claimPercent;
  final bool? hasGst;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'expenseCategoryId': expenseCategoryId,
        'entryDate': entryDate.toIso8601String().substring(0, 10),
        'grossAmount': grossAmount,
        'claimPercent': claimPercent,
        'hasGst': hasGst,
        'notes': notes,
      };
}
