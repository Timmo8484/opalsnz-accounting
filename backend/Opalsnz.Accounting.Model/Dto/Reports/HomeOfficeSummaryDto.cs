namespace Opalsnz.Accounting.Model.Dto.Reports;

public class HomeOfficeSummaryDto
{
    public DateOnly FromDate { get; set; }
    public DateOnly ToDate { get; set; }
    public List<HomeOfficeCategoryTotal> CategoryTotals { get; set; } = [];
    public decimal TotalGrossAmount { get; set; }
    public decimal TotalClaimableAmount { get; set; }
    public decimal TotalClaimableGst { get; set; }
}

public class HomeOfficeCategoryTotal
{
    public long ExpenseCategoryId { get; set; }
    public string ExpenseCategoryName { get; set; } = string.Empty;
    public decimal GrossAmount { get; set; }
    public decimal ClaimableAmount { get; set; }
    public decimal ClaimableGst { get; set; }
}
