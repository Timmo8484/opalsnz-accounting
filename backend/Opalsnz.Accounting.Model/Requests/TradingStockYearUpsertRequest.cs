using Opalsnz.Accounting.Model.Enums;

namespace Opalsnz.Accounting.Model.Requests;

public class TradingStockYearUpsertRequest
{
    public DateOnly TaxYearStart { get; set; }
    public DateOnly TaxYearEnd { get; set; }

    // Required only for the first ever tax year (no prior closing value to carry forward).
    public decimal? OpeningValue { get; set; }
    public OpeningValueMethod OpeningValueMethod { get; set; } = OpeningValueMethod.PriorYearClosing;

    public decimal? ClosingValue { get; set; }
    public ClosingValueMethod? ClosingValueMethod { get; set; }
    public bool IsFinalised { get; set; }
    public string? Notes { get; set; }
}
