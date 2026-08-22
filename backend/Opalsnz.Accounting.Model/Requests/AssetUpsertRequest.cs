using Opalsnz.Accounting.Model.Enums;

namespace Opalsnz.Accounting.Model.Requests;

public class AssetUpsertRequest
{
    public long? BusinessPurchaseId { get; set; }
    public string Description { get; set; } = string.Empty;
    public DateOnly PurchaseDate { get; set; }
    public decimal CostExclGst { get; set; }
    public DepreciationMethod DepreciationMethod { get; set; }
    public decimal DepreciationRate { get; set; }
    public DateOnly? DisposalDate { get; set; }
    public decimal? DisposalAmount { get; set; }
    public string? Notes { get; set; }
}
