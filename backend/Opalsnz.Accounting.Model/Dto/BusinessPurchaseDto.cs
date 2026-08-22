using Opalsnz.Accounting.Model.Enums;

namespace Opalsnz.Accounting.Model.Dto;

public class BusinessPurchaseDto
{
    public long Id { get; set; }
    public DateOnly PurchaseDate { get; set; }
    public PurchaseType PurchaseType { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? Supplier { get; set; }
    public decimal AmountExclGst { get; set; }
    public decimal GstAmount { get; set; }
    public bool IsCapitalAsset { get; set; }
    public bool IsTradingStockPurchase { get; set; }
    public string? Notes { get; set; }
}
