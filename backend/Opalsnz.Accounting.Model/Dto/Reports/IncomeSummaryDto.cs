using Opalsnz.Accounting.Model.Enums;

namespace Opalsnz.Accounting.Model.Dto.Reports;

public class IncomeSummaryDto
{
    public DateOnly FromDate { get; set; }
    public DateOnly ToDate { get; set; }
    public List<IncomeStreamTotal> StreamTotals { get; set; } = [];
    public decimal TotalAmountExclGst { get; set; }
    public decimal TotalGst { get; set; }
    public decimal GrandTotal { get; set; }
}

public class IncomeStreamTotal
{
    public IncomeStream IncomeStream { get; set; }
    public decimal AmountExclGst { get; set; }
    public decimal GstAmount { get; set; }
    public decimal Total { get; set; }
}
