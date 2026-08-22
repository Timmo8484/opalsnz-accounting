enum IncomeStream {
  softwareDevelopment('SoftwareDevelopment', 'Software Development'),
  opalSales('OpalSales', 'Opal Sales');

  const IncomeStream(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static IncomeStream fromWire(String value) =>
      IncomeStream.values.firstWhere((e) => e.wireValue == value);
}

class IncomeEntry {
  IncomeEntry({
    required this.id,
    required this.incomeStream,
    required this.entryDate,
    required this.description,
    this.invoiceReference,
    required this.amountExclGst,
    required this.gstAmount,
    required this.totalAmount,
    this.notes,
  });

  final int id;
  final IncomeStream incomeStream;
  final DateTime entryDate;
  final String description;
  final String? invoiceReference;
  final double amountExclGst;
  final double gstAmount;
  final double totalAmount;
  final String? notes;

  factory IncomeEntry.fromJson(Map<String, dynamic> json) => IncomeEntry(
        id: json['id'] as int,
        incomeStream: IncomeStream.fromWire(json['incomeStream'] as String),
        entryDate: DateTime.parse(json['entryDate'] as String),
        description: json['description'] as String,
        invoiceReference: json['invoiceReference'] as String?,
        amountExclGst: (json['amountExclGst'] as num).toDouble(),
        gstAmount: (json['gstAmount'] as num).toDouble(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toRequestJson() => {
        'incomeStream': incomeStream.wireValue,
        'entryDate': entryDate.toIso8601String().substring(0, 10),
        'description': description,
        'invoiceReference': invoiceReference,
        'amountExclGst': amountExclGst,
        'gstAmount': gstAmount,
        'notes': notes,
      };
}
