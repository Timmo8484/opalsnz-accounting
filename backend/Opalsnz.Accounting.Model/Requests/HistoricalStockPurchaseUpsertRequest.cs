namespace Opalsnz.Accounting.Model.Requests;

public class HistoricalStockPurchaseUpsertRequest
{
    public DateOnly PurchaseDate { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string? Notes { get; set; }
}
