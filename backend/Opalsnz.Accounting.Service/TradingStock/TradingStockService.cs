using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Db.Models;
using Opalsnz.Accounting.Model.Dto;
using Opalsnz.Accounting.Model.Enums;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.Calculators;

namespace Opalsnz.Accounting.Service.TradingStock;

public interface ITradingStockService
{
    Task<List<TradingStockYearDto>> GetAllAsync(CancellationToken ct = default);
    Task<TradingStockYearDto?> GetByIdAsync(long id, CancellationToken ct = default);

    // Throws InvalidOperationException if OpeningValueMethod is PriorYearClosing but no prior year exists.
    Task<TradingStockYearDto> CreateAsync(TradingStockYearUpsertRequest request, CancellationToken ct = default);
    Task<TradingStockYearDto?> UpdateAsync(long id, TradingStockYearUpsertRequest request, CancellationToken ct = default);
    Task<bool> DeleteAsync(long id, CancellationToken ct = default);
}

public class TradingStockService(AccountingContext db) : ITradingStockService
{
    public async Task<List<TradingStockYearDto>> GetAllAsync(CancellationToken ct = default)
    {
        var entities = await db.trading_stock_years.AsNoTracking().OrderByDescending(y => y.tax_year_start).ToListAsync(ct);
        var result = new List<TradingStockYearDto>();
        foreach (var entity in entities)
        {
            result.Add(await ToDtoAsync(entity, ct));
        }
        return result;
    }

    public async Task<TradingStockYearDto?> GetByIdAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.trading_stock_years.AsNoTracking().FirstOrDefaultAsync(y => y.id == id, ct);
        return entity is null ? null : await ToDtoAsync(entity, ct);
    }

    public async Task<TradingStockYearDto> CreateAsync(TradingStockYearUpsertRequest request, CancellationToken ct = default)
    {
        var openingValue = await ResolveOpeningValueAsync(request, ct);

        var entity = new trading_stock_year
        {
            tax_year_start = request.TaxYearStart,
            tax_year_end = request.TaxYearEnd,
            opening_value = openingValue,
            opening_value_method = request.OpeningValueMethod.ToString(),
            closing_value = request.ClosingValue,
            closing_value_method = request.ClosingValueMethod?.ToString(),
            is_finalised = request.IsFinalised,
            notes = request.Notes,
        };

        db.trading_stock_years.Add(entity);
        await db.SaveChangesAsync(ct);
        return await ToDtoAsync(entity, ct);
    }

    public async Task<TradingStockYearDto?> UpdateAsync(long id, TradingStockYearUpsertRequest request, CancellationToken ct = default)
    {
        var entity = await db.trading_stock_years.FirstOrDefaultAsync(y => y.id == id, ct);
        if (entity is null)
        {
            return null;
        }

        entity.tax_year_start = request.TaxYearStart;
        entity.tax_year_end = request.TaxYearEnd;
        entity.opening_value = await ResolveOpeningValueAsync(request, ct, excludeId: id);
        entity.opening_value_method = request.OpeningValueMethod.ToString();
        entity.closing_value = request.ClosingValue;
        entity.closing_value_method = request.ClosingValueMethod?.ToString();
        entity.is_finalised = request.IsFinalised;
        entity.notes = request.Notes;

        await db.SaveChangesAsync(ct);
        return await ToDtoAsync(entity, ct);
    }

    public async Task<bool> DeleteAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.trading_stock_years.FirstOrDefaultAsync(y => y.id == id, ct);
        if (entity is null)
        {
            return false;
        }

        db.trading_stock_years.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private async Task<decimal> ResolveOpeningValueAsync(TradingStockYearUpsertRequest request, CancellationToken ct, long? excludeId = null)
    {
        if (request.OpeningValueMethod != OpeningValueMethod.PriorYearClosing)
        {
            return request.OpeningValue
                ?? throw new InvalidOperationException("OpeningValue is required when OpeningValueMethod is Cost or MarketValue.");
        }

        var priorYear = await db.trading_stock_years
            .Where(y => y.tax_year_start < request.TaxYearStart && y.id != excludeId)
            .OrderByDescending(y => y.tax_year_start)
            .FirstOrDefaultAsync(ct);

        return priorYear?.closing_value
            ?? throw new InvalidOperationException("No prior trading stock year found to carry the closing value forward from.");
    }

    private async Task<TradingStockYearDto> ToDtoAsync(trading_stock_year entity, CancellationToken ct)
    {
        var purchasesThisYear = await db.business_purchases
            .Where(p => p.is_trading_stock_purchase
                && p.purchase_date >= entity.tax_year_start
                && p.purchase_date <= entity.tax_year_end)
            .SumAsync(p => p.amount_excl_gst, ct);

        return new TradingStockYearDto
        {
            Id = entity.id,
            TaxYearStart = entity.tax_year_start,
            TaxYearEnd = entity.tax_year_end,
            OpeningValue = entity.opening_value,
            OpeningValueMethod = Enum.Parse<OpeningValueMethod>(entity.opening_value_method),
            ClosingValue = entity.closing_value,
            ClosingValueMethod = entity.closing_value_method is null ? null : Enum.Parse<ClosingValueMethod>(entity.closing_value_method),
            IsFinalised = entity.is_finalised,
            Notes = entity.notes,
            DeductibleStockCost = entity.closing_value is null
                ? null
                : TradingStockCalculator.CalculateDeductibleCost(entity.opening_value, purchasesThisYear, entity.closing_value.Value),
        };
    }
}
