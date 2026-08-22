using Opalsnz.Accounting.Model.Enums;

namespace Opalsnz.Accounting.Model.Dto;

public class IncomeEntryDto
{
    public long Id { get; set; }
    public IncomeStream IncomeStream { get; set; }
    public DateOnly EntryDate { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? InvoiceReference { get; set; }
    public decimal AmountExclGst { get; set; }
    public decimal GstAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public string? Notes { get; set; }
}
