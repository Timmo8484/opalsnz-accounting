using Opalsnz.Accounting.Service.Calculators;
using Xunit;

namespace Opalsnz.Accounting.Tests.Calculators;

public class GstCalculatorTests
{
    [Theory]
    [InlineData(115, 15)]
    [InlineData(220, 28.70)]
    [InlineData(0, 0)]
    public void GetGstContent_ReturnsThreeTwentyThirdsOfGrossAmount(decimal grossAmount, decimal expectedGst)
    {
        var result = GstCalculator.GetGstContent(grossAmount);

        Assert.Equal(expectedGst, result);
    }

    [Fact]
    public void GetExclusiveAmount_SubtractsGstContentFromGrossAmount()
    {
        var result = GstCalculator.GetExclusiveAmount(115m);

        Assert.Equal(100m, result);
    }
}
