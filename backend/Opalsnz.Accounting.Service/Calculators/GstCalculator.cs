namespace Opalsnz.Accounting.Service.Calculators;

// See docs/tax/gst-quick-reference.md - GST is 15%, so the GST content of a GST-inclusive
// amount is amount x 3/23 (since 15/115 simplifies to 3/23).
public static class GstCalculator
{
    private const decimal GstContentNumerator = 3m;
    private const decimal GstContentDenominator = 23m;

    public static decimal GetGstContent(decimal grossAmount)
        => Math.Round(grossAmount * GstContentNumerator / GstContentDenominator, 2, MidpointRounding.AwayFromZero);

    public static decimal GetExclusiveAmount(decimal grossAmount)
        => Math.Round(grossAmount - GetGstContent(grossAmount), 2, MidpointRounding.AwayFromZero);
}
