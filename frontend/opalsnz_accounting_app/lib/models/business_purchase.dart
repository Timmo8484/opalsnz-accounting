enum PurchaseType {
  opalRoughStock('OpalRoughStock', 'Opal Rough Stock'),
  tool('Tool', 'Tool / Equipment'),
  other('Other', 'Other');

  const PurchaseType(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static PurchaseType fromWire(String value) => PurchaseType.values.firstWhere((e) => e.wireValue == value);
}

class BusinessPurchase {
  BusinessPurchase({
    required this.id,
    required this.purchaseDate,
    required this.purchaseType,
    required this.description,
    this.supplier,
    required this.amountExclGst,
    required this.gstAmount,
    required this.isCapitalAsset,
    required this.isTradingStockPurchase,
    this.notes,
  });

  final int id;
  final DateTime purchaseDate;
  final PurchaseType purchaseType;
  final String description;
  final String? supplier;
  final double amountExclGst;
  final double gstAmount;
  final bool isCapitalAsset;
  final bool isTradingStockPurchase;
  final String? notes;

  factory BusinessPurchase.fromJson(Map<String, dynamic> json) => BusinessPurchase(
        id: json['id'] as int,
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
        purchaseType: PurchaseType.fromWire(json['purchaseType'] as String),
        description: json['description'] as String,
        supplier: json['supplier'] as String?,
        amountExclGst: (json['amountExclGst'] as num).toDouble(),
        gstAmount: (json['gstAmount'] as num).toDouble(),
        isCapitalAsset: json['isCapitalAsset'] as bool,
        isTradingStockPurchase: json['isTradingStockPurchase'] as bool,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toRequestJson() => {
        'purchaseDate': purchaseDate.toIso8601String().substring(0, 10),
        'purchaseType': purchaseType.wireValue,
        'description': description,
        'supplier': supplier,
        'amountExclGst': amountExclGst,
        'gstAmount': gstAmount,
        'isCapitalAsset': isCapitalAsset,
        'isTradingStockPurchase': isTradingStockPurchase,
        'notes': notes,
      };
}
