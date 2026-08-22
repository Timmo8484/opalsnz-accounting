using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Model.Dto.Reports;
using Opalsnz.Accounting.Model.Enums;

namespace Opalsnz.Accounting.Service.Reports;

public interface IReportService
{
    Task<IncomeSummaryDto> GetIncomeSummaryAsync(DateOnly fromDate, DateOnly toDate, CancellationToken ct = default);
    Task<HomeOfficeSummaryDto> GetHomeOfficeSummaryAsync(DateOnly fromDate, DateOnly toDate, CancellationToken ct = default);
    Task<GstPeriodSummaryDto> GetGstPeriodSummaryAsync(DateOnly periodStart, DateOnly periodEnd, CancellationToken ct = default);
    Task<DepreciationScheduleDto> GetDepreciationScheduleAsync(DateOnly taxYearStart, DateOnly taxYearEnd, CancellationToken ct = default);
}

public class ReportService(AccountingContext db) : IReportService
{
    public async Task<IncomeSummaryDto> GetIncomeSummaryAsync(DateOnly fromDate, DateOnly toDate, CancellationToken ct = default)
    {
        var entries = await db.income_entries.AsNoTracking()
            .Where(e => e.entry_date >= fromDate && e.entry_date <= toDate)
            .ToListAsync(ct);

        var streamTotals = entries
            .GroupBy(e => e.income_stream)
            .Select(g => new IncomeStreamTotal
            {
                IncomeStream = Enum.Parse<IncomeStream>(g.Key),
                AmountExclGst = g.Sum(e => e.amount_excl_gst),
                GstAmount = g.Sum(e => e.gst_amount),
                Total = g.Sum(e => e.total_amount),
            })
            .OrderBy(t => t.IncomeStream)
            .ToList();

        return new IncomeSummaryDto
        {
            FromDate = fromDate,
            ToDate = toDate,
            StreamTotals = streamTotals,
            TotalAmountExclGst = streamTotals.Sum(t => t.AmountExclGst),
            TotalGst = streamTotals.Sum(t => t.GstAmount),
            GrandTotal = streamTotals.Sum(t => t.Total),
        };
    }

    public async Task<HomeOfficeSummaryDto> GetHomeOfficeSummaryAsync(DateOnly fromDate, DateOnly toDate, CancellationToken ct = default)
    {
        var entries = await db.home_office_expense_entries.AsNoTracking()
            .Include(e => e.expense_category)
            .Where(e => e.entry_date >= fromDate && e.entry_date <= toDate)
            .ToListAsync(ct);

        var categoryTotals = entries
            .GroupBy(e => new { e.expense_category_id, e.expense_category.name })
            .Select(g => new HomeOfficeCategoryTotal
            {
                ExpenseCategoryId = g.Key.expense_category_id,
                ExpenseCategoryName = g.Key.name,
                GrossAmount = g.Sum(e => e.gross_amount),
                ClaimableAmount = g.Sum(e => e.claimable_amount),
                ClaimableGst = g.Sum(e => e.claimable_gst),
            })
            .OrderBy(t => t.ExpenseCategoryName)
            .ToList();

        return new HomeOfficeSummaryDto
        {
            FromDate = fromDate,
            ToDate = toDate,
            CategoryTotals = categoryTotals,
            TotalGrossAmount = categoryTotals.Sum(t => t.GrossAmount),
            TotalClaimableAmount = categoryTotals.Sum(t => t.ClaimableAmount),
            TotalClaimableGst = categoryTotals.Sum(t => t.ClaimableGst),
        };
    }

    public async Task<GstPeriodSummaryDto> GetGstPeriodSummaryAsync(DateOnly periodStart, DateOnly periodEnd, CancellationToken ct = default)
    {
        var outputGst = await db.income_entries.AsNoTracking()
            .Where(e => e.entry_date >= periodStart && e.entry_date <= periodEnd)
            .SumAsync(e => e.gst_amount, ct);

        var homeOfficeInputGst = await db.home_office_expense_entries.AsNoTracking()
            .Where(e => e.entry_date >= periodStart && e.entry_date <= periodEnd)
            .SumAsync(e => e.claimable_gst, ct);

        var purchaseInputGst = await db.business_purchases.AsNoTracking()
            .Where(p => p.purchase_date >= periodStart && p.purchase_date <= periodEnd)
            .SumAsync(p => p.gst_amount, ct);

        var inputGst = homeOfficeInputGst + purchaseInputGst;

        return new GstPeriodSummaryDto
        {
            PeriodStart = periodStart,
            PeriodEnd = periodEnd,
            OutputGst = outputGst,
            InputGst = inputGst,
            NetGst = outputGst - inputGst,
        };
    }

    public async Task<DepreciationScheduleDto> GetDepreciationScheduleAsync(DateOnly taxYearStart, DateOnly taxYearEnd, CancellationToken ct = default)
    {
        var years = await db.asset_depreciation_years.AsNoTracking()
            .Include(y => y.asset)
            .Where(y => y.tax_year_start == taxYearStart && y.tax_year_end == taxYearEnd)
            .ToListAsync(ct);

        var lines = years
            .Select(y => new DepreciationScheduleLine
            {
                AssetId = y.asset_id,
                AssetDescription = y.asset.description,
                OpeningValue = y.opening_value,
                DepreciationAmount = y.depreciation_amount,
                ClosingValue = y.closing_value,
            })
            .OrderBy(l => l.AssetDescription)
            .ToList();

        return new DepreciationScheduleDto
        {
            TaxYearStart = taxYearStart,
            TaxYearEnd = taxYearEnd,
            Lines = lines,
            TotalDepreciation = lines.Sum(l => l.DepreciationAmount),
        };
    }
}
