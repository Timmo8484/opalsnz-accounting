namespace Opalsnz.Accounting.Model.Dto;

public class HistoricalStockPurchaseDto
{
    public long Id { get; set; }
    public DateOnly PurchaseDate { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string? Notes { get; set; }
}
