using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Service.Reports;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/reports")]
public class ReportsController(IReportService reportService) : ControllerBase
{
    [HttpGet("income-summary")]
    public async Task<IActionResult> IncomeSummary([FromQuery] DateOnly fromDate, [FromQuery] DateOnly toDate, CancellationToken ct)
        => Ok(await reportService.GetIncomeSummaryAsync(fromDate, toDate, ct));

    [HttpGet("home-office-summary")]
    public async Task<IActionResult> HomeOfficeSummary([FromQuery] DateOnly fromDate, [FromQuery] DateOnly toDate, CancellationToken ct)
        => Ok(await reportService.GetHomeOfficeSummaryAsync(fromDate, toDate, ct));

    [HttpGet("gst-period-summary")]
    public async Task<IActionResult> GstPeriodSummary([FromQuery] DateOnly periodStart, [FromQuery] DateOnly periodEnd, CancellationToken ct)
        => Ok(await reportService.GetGstPeriodSummaryAsync(periodStart, periodEnd, ct));

    [HttpGet("depreciation-schedule")]
    public async Task<IActionResult> DepreciationSchedule([FromQuery] DateOnly taxYearStart, [FromQuery] DateOnly taxYearEnd, CancellationToken ct)
        => Ok(await reportService.GetDepreciationScheduleAsync(taxYearStart, taxYearEnd, ct));
}
