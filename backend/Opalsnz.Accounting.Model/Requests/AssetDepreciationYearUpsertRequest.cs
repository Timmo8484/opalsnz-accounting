namespace Opalsnz.Accounting.Model.Requests;

// Opening value, depreciation amount, and closing value are calculated by the service -
// the caller only supplies the year and how many months the asset was owned during it.
public class AssetDepreciationYearUpsertRequest
{
    public long AssetId { get; set; }
    public DateOnly TaxYearStart { get; set; }
    public DateOnly TaxYearEnd { get; set; }
    public int MonthsOwnedThisYear { get; set; } = 12;
}
