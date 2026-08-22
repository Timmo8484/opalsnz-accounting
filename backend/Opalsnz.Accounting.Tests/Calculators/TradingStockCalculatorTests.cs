using Opalsnz.Accounting.Service.Calculators;
using Xunit;

namespace Opalsnz.Accounting.Tests.Calculators;

public class TradingStockCalculatorTests
{
    [Fact]
    public void CalculateDeductibleCost_OpeningPlusPurchasesMinusClosing()
    {
        var result = TradingStockCalculator.CalculateDeductibleCost(
            openingValue: 50000m,
            purchasesThisYear: 5000m,
            closingValue: 48000m);

        Assert.Equal(7000m, result);
    }

    [Fact]
    public void CalculateDeductibleCost_CanBeNegative_WhenClosingStockGrewMoreThanPurchases()
    {
        var result = TradingStockCalculator.CalculateDeductibleCost(
            openingValue: 50000m,
            purchasesThisYear: 1000m,
            closingValue: 55000m);

        Assert.Equal(-4000m, result);
    }
}
