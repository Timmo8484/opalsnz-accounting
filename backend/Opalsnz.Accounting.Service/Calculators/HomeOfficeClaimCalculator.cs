namespace Opalsnz.Accounting.Service.Calculators;

// See docs/tax/home-office-expenses.md - claimable amount is the gross cost times a fixed,
// user-set % per category; GST is calculated on the claimable (post-apportionment) amount.
public static class HomeOfficeClaimCalculator
{
    public static decimal CalculateClaimableAmount(decimal grossAmount, decimal claimPercent)
        => Math.Round(grossAmount * claimPercent / 100m, 2, MidpointRounding.AwayFromZero);

    public static decimal CalculateClaimableGst(decimal claimableAmount, bool hasGst)
        => hasGst ? GstCalculator.GetGstContent(claimableAmount) : 0m;
}
