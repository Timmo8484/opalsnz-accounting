namespace Opalsnz.Accounting.Model.Dto.Reports;

public class DepreciationScheduleDto
{
    public DateOnly TaxYearStart { get; set; }
    public DateOnly TaxYearEnd { get; set; }
    public List<DepreciationScheduleLine> Lines { get; set; } = [];
    public decimal TotalDepreciation { get; set; }
}

public class DepreciationScheduleLine
{
    public long AssetId { get; set; }
    public string AssetDescription { get; set; } = string.Empty;
    public decimal OpeningValue { get; set; }
    public decimal DepreciationAmount { get; set; }
    public decimal ClosingValue { get; set; }
}
