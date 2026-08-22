namespace Opalsnz.Accounting.Model.Requests;

public class HomeOfficeExpenseEntryUpsertRequest
{
    public long ExpenseCategoryId { get; set; }
    public DateOnly EntryDate { get; set; }
    public decimal GrossAmount { get; set; }

    // Optional overrides - if not supplied, the category's current default/HasGst are snapshotted.
    public decimal? ClaimPercent { get; set; }
    public bool? HasGst { get; set; }
    public string? Notes { get; set; }
}
