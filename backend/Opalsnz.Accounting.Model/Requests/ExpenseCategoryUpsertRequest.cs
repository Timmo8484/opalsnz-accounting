namespace Opalsnz.Accounting.Model.Requests;

public class ExpenseCategoryUpsertRequest
{
    public string Name { get; set; } = string.Empty;
    public decimal DefaultClaimPercent { get; set; }
    public bool HasGst { get; set; } = true;
    public bool IsActive { get; set; } = true;
}
