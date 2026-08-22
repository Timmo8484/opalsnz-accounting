using Opalsnz.Accounting.Model.Enums;

namespace Opalsnz.Accounting.Model.Dto;

public class TradingStockYearDto
{
    public long Id { get; set; }
    public DateOnly TaxYearStart { get; set; }
    public DateOnly TaxYearEnd { get; set; }
    public decimal OpeningValue { get; set; }
    public OpeningValueMethod OpeningValueMethod { get; set; }
    public decimal? ClosingValue { get; set; }
    public ClosingValueMethod? ClosingValueMethod { get; set; }
    public bool IsFinalised { get; set; }
    public string? Notes { get; set; }

    // Opening + this tax year's trading-stock purchases - closing (null until closing value is set).
    public decimal? DeductibleStockCost { get; set; }
}
