enum OpeningValueMethod {
  cost('Cost', 'Cost'),
  marketValue('MarketValue', 'Market Value'),
  priorYearClosing('PriorYearClosing', "Prior Year's Closing Value");

  const OpeningValueMethod(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static OpeningValueMethod fromWire(String value) =>
      OpeningValueMethod.values.firstWhere((e) => e.wireValue == value);
}

enum ClosingValueMethod {
  cost('Cost', 'Cost'),
  discountedSellingPrice('DiscountedSellingPrice', 'Discounted Selling Price'),
  replacementPrice('ReplacementPrice', 'Replacement Price'),
  marketSellingValue('MarketSellingValue', 'Market Selling Value');

  const ClosingValueMethod(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static ClosingValueMethod fromWire(String value) =>
      ClosingValueMethod.values.firstWhere((e) => e.wireValue == value);
}

class TradingStockYear {
  TradingStockYear({
    required this.id,
    required this.taxYearStart,
    required this.taxYearEnd,
    required this.openingValue,
    required this.openingValueMethod,
    this.closingValue,
    this.closingValueMethod,
    required this.isFinalised,
    this.notes,
    this.deductibleStockCost,
  });

  final int id;
  final DateTime taxYearStart;
  final DateTime taxYearEnd;
  final double openingValue;
  final OpeningValueMethod openingValueMethod;
  final double? closingValue;
  final ClosingValueMethod? closingValueMethod;
  final bool isFinalised;
  final String? notes;
  final double? deductibleStockCost;

  factory TradingStockYear.fromJson(Map<String, dynamic> json) =>
      TradingStockYear(
        id: json['id'] as int,
        taxYearStart: DateTime.parse(json['taxYearStart'] as String),
        taxYearEnd: DateTime.parse(json['taxYearEnd'] as String),
        openingValue: (json['openingValue'] as num).toDouble(),
        openingValueMethod: OpeningValueMethod.fromWire(
          json['openingValueMethod'] as String,
        ),
        closingValue: (json['closingValue'] as num?)?.toDouble(),
        closingValueMethod: json['closingValueMethod'] == null
            ? null
            : ClosingValueMethod.fromWire(json['closingValueMethod'] as String),
        isFinalised: json['isFinalised'] as bool,
        notes: json['notes'] as String?,
        deductibleStockCost: (json['deductibleStockCost'] as num?)?.toDouble(),
      );
}

class HistoricalStockPurchase {
  HistoricalStockPurchase({
    required this.id,
    required this.purchaseDate,
    required this.description,
    required this.amount,
    this.notes,
  });

  final int id;
  final DateTime purchaseDate;
  final String description;
  final double amount;
  final String? notes;

  factory HistoricalStockPurchase.fromJson(Map<String, dynamic> json) =>
      HistoricalStockPurchase(
        id: json['id'] as int,
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toRequestJson() => {
    'purchaseDate': purchaseDate.toIso8601String().substring(0, 10),
    'description': description,
    'amount': amount,
    'notes': notes,
  };
}
