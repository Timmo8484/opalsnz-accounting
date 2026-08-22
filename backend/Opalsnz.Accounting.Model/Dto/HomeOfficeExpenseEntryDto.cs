namespace Opalsnz.Accounting.Model.Dto;

public class HomeOfficeExpenseEntryDto
{
    public long Id { get; set; }
    public long ExpenseCategoryId { get; set; }
    public string ExpenseCategoryName { get; set; } = string.Empty;
    public DateOnly EntryDate { get; set; }
    public decimal GrossAmount { get; set; }
    public decimal ClaimPercent { get; set; }
    public bool HasGst { get; set; }
    public decimal ClaimableAmount { get; set; }
    public decimal ClaimableGst { get; set; }
    public string? Notes { get; set; }
}
