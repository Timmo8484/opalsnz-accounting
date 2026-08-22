namespace Opalsnz.Accounting.Model.Dto;

public class AssetDepreciationYearDto
{
    public long Id { get; set; }
    public long AssetId { get; set; }
    public DateOnly TaxYearStart { get; set; }
    public DateOnly TaxYearEnd { get; set; }
    public decimal OpeningValue { get; set; }
    public decimal DepreciationAmount { get; set; }
    public decimal ClosingValue { get; set; }
    public int MonthsOwnedThisYear { get; set; }
}
