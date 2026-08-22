using Opalsnz.Accounting.Model.Enums;

namespace Opalsnz.Accounting.Service.Calculators;

// See docs/tax/depreciation-cheatsheet.md - low-value asset threshold, DV/SL formulas, part-year
// apportionment by months owned.
public static class DepreciationCalculator
{
    public const decimal LowValueAssetThreshold = 1000m;

    public static bool IsLowValueWriteOff(decimal costExclGst) => costExclGst <= LowValueAssetThreshold;

    public static decimal CalculateDiminishingValue(decimal openingValue, decimal ratePercent, int monthsOwned = 12)
        => CapAtOpeningValue(openingValue, Apportion(openingValue * ratePercent / 100m, monthsOwned));

    public static decimal CalculateStraightLine(decimal costExclGst, decimal openingValue, decimal ratePercent, int monthsOwned = 12)
        => CapAtOpeningValue(openingValue, Apportion(costExclGst * ratePercent / 100m, monthsOwned));

    public static decimal CalculateDepreciation(
        DepreciationMethod method,
        decimal costExclGst,
        decimal openingValue,
        decimal ratePercent,
        int monthsOwned = 12)
        => method switch
        {
            DepreciationMethod.DiminishingValue => CalculateDiminishingValue(openingValue, ratePercent, monthsOwned),
            DepreciationMethod.StraightLine => CalculateStraightLine(costExclGst, openingValue, ratePercent, monthsOwned),
            _ => throw new ArgumentOutOfRangeException(nameof(method), method, "Unknown depreciation method"),
        };

    private static decimal Apportion(decimal fullYearAmount, int monthsOwned)
        => Math.Round(fullYearAmount * monthsOwned / 12m, 2, MidpointRounding.AwayFromZero);

    // Book value can never go below zero.
    private static decimal CapAtOpeningValue(decimal openingValue, decimal depreciation)
        => Math.Min(depreciation, openingValue);
}
