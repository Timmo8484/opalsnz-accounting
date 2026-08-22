namespace Opalsnz.Accounting.Model.Dto.Reports;

public class GstPeriodSummaryDto
{
    public DateOnly PeriodStart { get; set; }
    public DateOnly PeriodEnd { get; set; }
    public decimal OutputGst { get; set; }
    public decimal InputGst { get; set; }
    public decimal NetGst { get; set; }
}
