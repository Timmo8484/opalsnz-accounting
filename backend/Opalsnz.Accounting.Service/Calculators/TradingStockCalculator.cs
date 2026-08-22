namespace Opalsnz.Accounting.Service.Calculators;

// See docs/tax/trading-stock-and-startup-assets.md - periodic method: deductible stock cost for the
// year = opening value + purchases during the year - closing value.
public static class TradingStockCalculator
{
    public static decimal CalculateDeductibleCost(decimal openingValue, decimal purchasesThisYear, decimal closingValue)
        => openingValue + purchasesThisYear - closingValue;
}
