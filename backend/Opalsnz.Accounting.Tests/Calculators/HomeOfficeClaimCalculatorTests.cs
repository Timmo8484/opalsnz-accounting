using Opalsnz.Accounting.Service.Calculators;
using Xunit;

namespace Opalsnz.Accounting.Tests.Calculators;

public class HomeOfficeClaimCalculatorTests
{
    [Fact]
    public void CalculateClaimableAmount_AppliesClaimPercentToGrossAmount()
    {
        var result = HomeOfficeClaimCalculator.CalculateClaimableAmount(220m, 50m);

        Assert.Equal(110m, result);
    }

    [Fact]
    public void CalculateClaimableGst_ReturnsGstContentOfClaimableAmount_WhenCategoryHasGst()
    {
        var claimable = HomeOfficeClaimCalculator.CalculateClaimableAmount(220m, 50m);

        var result = HomeOfficeClaimCalculator.CalculateClaimableGst(claimable, hasGst: true);

        Assert.Equal(14.35m, result);
    }

    [Fact]
    public void CalculateClaimableGst_ReturnsZero_WhenCategoryHasNoGst()
    {
        // e.g. mortgage interest - financial services are GST-exempt.
        var claimable = HomeOfficeClaimCalculator.CalculateClaimableAmount(1200m, 25m);

        var result = HomeOfficeClaimCalculator.CalculateClaimableGst(claimable, hasGst: false);

        Assert.Equal(0m, result);
    }
}
