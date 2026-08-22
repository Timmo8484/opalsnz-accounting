import 'income_entry.dart';

class IncomeStreamTotal {
  IncomeStreamTotal({
    required this.incomeStream,
    required this.amountExclGst,
    required this.gstAmount,
    required this.total,
  });

  final IncomeStream incomeStream;
  final double amountExclGst;
  final double gstAmount;
  final double total;

  factory IncomeStreamTotal.fromJson(Map<String, dynamic> json) =>
      IncomeStreamTotal(
        incomeStream: IncomeStream.fromWire(json['incomeStream'] as String),
        amountExclGst: (json['amountExclGst'] as num).toDouble(),
        gstAmount: (json['gstAmount'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
      );
}

class IncomeSummary {
  IncomeSummary({
    required this.fromDate,
    required this.toDate,
    required this.streamTotals,
    required this.totalAmountExclGst,
    required this.totalGst,
    required this.grandTotal,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final List<IncomeStreamTotal> streamTotals;
  final double totalAmountExclGst;
  final double totalGst;
  final double grandTotal;

  factory IncomeSummary.fromJson(Map<String, dynamic> json) => IncomeSummary(
    fromDate: DateTime.parse(json['fromDate'] as String),
    toDate: DateTime.parse(json['toDate'] as String),
    streamTotals: (json['streamTotals'] as List)
        .map((e) => IncomeStreamTotal.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalAmountExclGst: (json['totalAmountExclGst'] as num).toDouble(),
    totalGst: (json['totalGst'] as num).toDouble(),
    grandTotal: (json['grandTotal'] as num).toDouble(),
  );
}

class HomeOfficeCategoryTotal {
  HomeOfficeCategoryTotal({
    required this.expenseCategoryId,
    required this.expenseCategoryName,
    required this.grossAmount,
    required this.claimableAmount,
    required this.claimableGst,
  });

  final int expenseCategoryId;
  final String expenseCategoryName;
  final double grossAmount;
  final double claimableAmount;
  final double claimableGst;

  factory HomeOfficeCategoryTotal.fromJson(Map<String, dynamic> json) =>
      HomeOfficeCategoryTotal(
        expenseCategoryId: json['expenseCategoryId'] as int,
        expenseCategoryName: json['expenseCategoryName'] as String,
        grossAmount: (json['grossAmount'] as num).toDouble(),
        claimableAmount: (json['claimableAmount'] as num).toDouble(),
        claimableGst: (json['claimableGst'] as num).toDouble(),
      );
}

class HomeOfficeSummary {
  HomeOfficeSummary({
    required this.fromDate,
    required this.toDate,
    required this.categoryTotals,
    required this.totalGrossAmount,
    required this.totalClaimableAmount,
    required this.totalClaimableGst,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final List<HomeOfficeCategoryTotal> categoryTotals;
  final double totalGrossAmount;
  final double totalClaimableAmount;
  final double totalClaimableGst;

  factory HomeOfficeSummary.fromJson(Map<String, dynamic> json) =>
      HomeOfficeSummary(
        fromDate: DateTime.parse(json['fromDate'] as String),
        toDate: DateTime.parse(json['toDate'] as String),
        categoryTotals: (json['categoryTotals'] as List)
            .map(
              (e) =>
                  HomeOfficeCategoryTotal.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        totalGrossAmount: (json['totalGrossAmount'] as num).toDouble(),
        totalClaimableAmount: (json['totalClaimableAmount'] as num).toDouble(),
        totalClaimableGst: (json['totalClaimableGst'] as num).toDouble(),
      );
}

class GstPeriodSummary {
  GstPeriodSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.outputGst,
    required this.inputGst,
    required this.netGst,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final double outputGst;
  final double inputGst;
  final double netGst;

  factory GstPeriodSummary.fromJson(Map<String, dynamic> json) =>
      GstPeriodSummary(
        periodStart: DateTime.parse(json['periodStart'] as String),
        periodEnd: DateTime.parse(json['periodEnd'] as String),
        outputGst: (json['outputGst'] as num).toDouble(),
        inputGst: (json['inputGst'] as num).toDouble(),
        netGst: (json['netGst'] as num).toDouble(),
      );
}

class DepreciationScheduleLine {
  DepreciationScheduleLine({
    required this.assetId,
    required this.assetDescription,
    required this.openingValue,
    required this.depreciationAmount,
    required this.closingValue,
  });

  final int assetId;
  final String assetDescription;
  final double openingValue;
  final double depreciationAmount;
  final double closingValue;

  factory DepreciationScheduleLine.fromJson(Map<String, dynamic> json) =>
      DepreciationScheduleLine(
        assetId: json['assetId'] as int,
        assetDescription: json['assetDescription'] as String,
        openingValue: (json['openingValue'] as num).toDouble(),
        depreciationAmount: (json['depreciationAmount'] as num).toDouble(),
        closingValue: (json['closingValue'] as num).toDouble(),
      );
}

class DepreciationSchedule {
  DepreciationSchedule({
    required this.taxYearStart,
    required this.taxYearEnd,
    required this.lines,
    required this.totalDepreciation,
  });

  final DateTime taxYearStart;
  final DateTime taxYearEnd;
  final List<DepreciationScheduleLine> lines;
  final double totalDepreciation;

  factory DepreciationSchedule.fromJson(Map<String, dynamic> json) =>
      DepreciationSchedule(
        taxYearStart: DateTime.parse(json['taxYearStart'] as String),
        taxYearEnd: DateTime.parse(json['taxYearEnd'] as String),
        lines: (json['lines'] as List)
            .map(
              (e) =>
                  DepreciationScheduleLine.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        totalDepreciation: (json['totalDepreciation'] as num).toDouble(),
      );
}
