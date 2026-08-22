using Opalsnz.Accounting.Model.Enums;
using Opalsnz.Accounting.Service.Calculators;
using Xunit;

namespace Opalsnz.Accounting.Tests.Calculators;

public class DepreciationCalculatorTests
{
    [Theory]
    [InlineData(1000, true)]
    [InlineData(999.99, true)]
    [InlineData(1000.01, false)]
    [InlineData(2400, false)]
    public void IsLowValueWriteOff_UsesOneThousandDollarThreshold(decimal costExclGst, bool expected)
    {
        Assert.Equal(expected, DepreciationCalculator.IsLowValueWriteOff(costExclGst));
    }

    [Fact]
    public void CalculateDiminishingValue_FullYear_AppliesRateToOpeningValue()
    {
        var result = DepreciationCalculator.CalculateDiminishingValue(openingValue: 2400m, ratePercent: 20m);

        Assert.Equal(480m, result);
    }

    [Fact]
    public void CalculateDiminishingValue_PartYear_ApportionsByMonthsOwned()
    {
        // Worked example from docs/tax/depreciation-cheatsheet.md: $2,400 asset, DV 20%, 6 months owned.
        var result = DepreciationCalculator.CalculateDiminishingValue(openingValue: 2400m, ratePercent: 20m, monthsOwned: 6);

        Assert.Equal(240m, result);
    }

    [Fact]
    public void CalculateDiminishingValue_SecondYear_UsesReducedOpeningValue()
    {
        // Year 2 from the same worked example: opening value 2160 (2400 - 240).
        var result = DepreciationCalculator.CalculateDiminishingValue(openingValue: 2160m, ratePercent: 20m);

        Assert.Equal(432m, result);
    }

    [Fact]
    public void CalculateStraightLine_UsesOriginalCostNotOpeningValue()
    {
        var result = DepreciationCalculator.CalculateStraightLine(costExclGst: 2400m, openingValue: 1200m, ratePercent: 20m);

        Assert.Equal(480m, result);
    }

    [Fact]
    public void CalculateDepreciation_NeverExceedsOpeningValue()
    {
        var result = DepreciationCalculator.CalculateDepreciation(
            DepreciationMethod.DiminishingValue,
            costExclGst: 2400m,
            openingValue: 50m,
            ratePercent: 200m);

        Assert.Equal(50m, result);
    }

    [Fact]
    public void CalculateDepreciation_DispatchesToStraightLine()
    {
        var result = DepreciationCalculator.CalculateDepreciation(
            DepreciationMethod.StraightLine,
            costExclGst: 2400m,
            openingValue: 2400m,
            ratePercent: 20m);

        Assert.Equal(480m, result);
    }
}
