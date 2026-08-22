using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Db.Models;
using Opalsnz.Accounting.Model.Dto;
using Opalsnz.Accounting.Model.Requests;

namespace Opalsnz.Accounting.Service.TradingStock;

// Record-keeping only for the ~3 years of pre-business bank-statement purchases - evidence for the
// TradingStockYear opening value, not itself part of any tax calculation. See
// docs/tax/trading-stock-and-startup-assets.md.
public interface IHistoricalStockPurchaseService
{
    Task<List<HistoricalStockPurchaseDto>> GetAllAsync(CancellationToken ct = default);
    Task<HistoricalStockPurchaseDto> CreateAsync(HistoricalStockPurchaseUpsertRequest request, CancellationToken ct = default);
    Task<HistoricalStockPurchaseDto?> UpdateAsync(long id, HistoricalStockPurchaseUpsertRequest request, CancellationToken ct = default);
    Task<bool> DeleteAsync(long id, CancellationToken ct = default);
}

public class HistoricalStockPurchaseService(AccountingContext db) : IHistoricalStockPurchaseService
{
    public async Task<List<HistoricalStockPurchaseDto>> GetAllAsync(CancellationToken ct = default)
    {
        var entities = await db.historical_stock_purchases.AsNoTracking().OrderBy(p => p.purchase_date).ToListAsync(ct);
        return entities.Select(ToDto).ToList();
    }

    public async Task<HistoricalStockPurchaseDto> CreateAsync(HistoricalStockPurchaseUpsertRequest request, CancellationToken ct = default)
    {
        var entity = new historical_stock_purchase
        {
            purchase_date = request.PurchaseDate,
            description = request.Description,
            amount = request.Amount,
            notes = request.Notes,
        };

        db.historical_stock_purchases.Add(entity);
        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<HistoricalStockPurchaseDto?> UpdateAsync(long id, HistoricalStockPurchaseUpsertRequest request, CancellationToken ct = default)
    {
        var entity = await db.historical_stock_purchases.FirstOrDefaultAsync(p => p.id == id, ct);
        if (entity is null)
        {
            return null;
        }

        entity.purchase_date = request.PurchaseDate;
        entity.description = request.Description;
        entity.amount = request.Amount;
        entity.notes = request.Notes;

        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<bool> DeleteAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.historical_stock_purchases.FirstOrDefaultAsync(p => p.id == id, ct);
        if (entity is null)
        {
            return false;
        }

        db.historical_stock_purchases.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private static HistoricalStockPurchaseDto ToDto(historical_stock_purchase entity) => new()
    {
        Id = entity.id,
        PurchaseDate = entity.purchase_date,
        Description = entity.description,
        Amount = entity.amount,
        Notes = entity.notes,
    };
}
