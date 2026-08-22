enum DepreciationMethod {
  diminishingValue('DiminishingValue', 'Diminishing Value'),
  straightLine('StraightLine', 'Straight Line');

  const DepreciationMethod(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static DepreciationMethod fromWire(String value) =>
      DepreciationMethod.values.firstWhere((e) => e.wireValue == value);
}

class Asset {
  Asset({
    required this.id,
    this.businessPurchaseId,
    required this.description,
    required this.purchaseDate,
    required this.costExclGst,
    required this.depreciationMethod,
    required this.depreciationRate,
    required this.isLowValueWriteoff,
    this.disposalDate,
    this.disposalAmount,
    this.notes,
  });

  final int id;
  final int? businessPurchaseId;
  final String description;
  final DateTime purchaseDate;
  final double costExclGst;
  final DepreciationMethod depreciationMethod;
  final double depreciationRate;
  final bool isLowValueWriteoff;
  final DateTime? disposalDate;
  final double? disposalAmount;
  final String? notes;

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    id: json['id'] as int,
    businessPurchaseId: json['businessPurchaseId'] as int?,
    description: json['description'] as String,
    purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    costExclGst: (json['costExclGst'] as num).toDouble(),
    depreciationMethod: DepreciationMethod.fromWire(
      json['depreciationMethod'] as String,
    ),
    depreciationRate: (json['depreciationRate'] as num).toDouble(),
    isLowValueWriteoff: json['isLowValueWriteoff'] as bool,
    disposalDate: json['disposalDate'] == null
        ? null
        : DateTime.parse(json['disposalDate'] as String),
    disposalAmount: (json['disposalAmount'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toRequestJson() => {
    'businessPurchaseId': businessPurchaseId,
    'description': description,
    'purchaseDate': purchaseDate.toIso8601String().substring(0, 10),
    'costExclGst': costExclGst,
    'depreciationMethod': depreciationMethod.wireValue,
    'depreciationRate': depreciationRate,
    'disposalDate': disposalDate?.toIso8601String().substring(0, 10),
    'disposalAmount': disposalAmount,
    'notes': notes,
  };
}

class AssetDepreciationYear {
  AssetDepreciationYear({
    required this.id,
    required this.assetId,
    required this.taxYearStart,
    required this.taxYearEnd,
    required this.openingValue,
    required this.depreciationAmount,
    required this.closingValue,
    required this.monthsOwnedThisYear,
  });

  final int id;
  final int assetId;
  final DateTime taxYearStart;
  final DateTime taxYearEnd;
  final double openingValue;
  final double depreciationAmount;
  final double closingValue;
  final int monthsOwnedThisYear;

  factory AssetDepreciationYear.fromJson(Map<String, dynamic> json) =>
      AssetDepreciationYear(
        id: json['id'] as int,
        assetId: json['assetId'] as int,
        taxYearStart: DateTime.parse(json['taxYearStart'] as String),
        taxYearEnd: DateTime.parse(json['taxYearEnd'] as String),
        openingValue: (json['openingValue'] as num).toDouble(),
        depreciationAmount: (json['depreciationAmount'] as num).toDouble(),
        closingValue: (json['closingValue'] as num).toDouble(),
        monthsOwnedThisYear: json['monthsOwnedThisYear'] as int,
      );
}
