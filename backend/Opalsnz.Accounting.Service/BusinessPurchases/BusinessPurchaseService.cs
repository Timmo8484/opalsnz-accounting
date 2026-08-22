using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Db.Models;
using Opalsnz.Accounting.Model.Dto;
using Opalsnz.Accounting.Model.Enums;
using Opalsnz.Accounting.Model.Requests;

namespace Opalsnz.Accounting.Service.BusinessPurchases;

public interface IBusinessPurchaseService
{
    Task<List<BusinessPurchaseDto>> GetAllAsync(DateOnly? fromDate, DateOnly? toDate, CancellationToken ct = default);
    Task<BusinessPurchaseDto?> GetByIdAsync(long id, CancellationToken ct = default);
    Task<BusinessPurchaseDto> CreateAsync(BusinessPurchaseUpsertRequest request, CancellationToken ct = default);
    Task<BusinessPurchaseDto?> UpdateAsync(long id, BusinessPurchaseUpsertRequest request, CancellationToken ct = default);
    Task<bool> DeleteAsync(long id, CancellationToken ct = default);
}

public class BusinessPurchaseService(AccountingContext db) : IBusinessPurchaseService
{
    public async Task<List<BusinessPurchaseDto>> GetAllAsync(DateOnly? fromDate, DateOnly? toDate, CancellationToken ct = default)
    {
        var query = db.business_purchases.AsNoTracking().AsQueryable();
        if (fromDate is not null)
        {
            query = query.Where(p => p.purchase_date >= fromDate);
        }
        if (toDate is not null)
        {
            query = query.Where(p => p.purchase_date <= toDate);
        }

        var entities = await query.OrderByDescending(p => p.purchase_date).ToListAsync(ct);
        return entities.Select(ToDto).ToList();
    }

    public async Task<BusinessPurchaseDto?> GetByIdAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.business_purchases.AsNoTracking().FirstOrDefaultAsync(p => p.id == id, ct);
        return entity is null ? null : ToDto(entity);
    }

    public async Task<BusinessPurchaseDto> CreateAsync(BusinessPurchaseUpsertRequest request, CancellationToken ct = default)
    {
        var entity = new business_purchase
        {
            purchase_date = request.PurchaseDate,
            purchase_type = request.PurchaseType.ToString(),
            description = request.Description,
            supplier = request.Supplier,
            amount_excl_gst = request.AmountExclGst,
            gst_amount = request.GstAmount,
            is_capital_asset = request.IsCapitalAsset,
            is_trading_stock_purchase = request.IsTradingStockPurchase,
            notes = request.Notes,
        };

        db.business_purchases.Add(entity);
        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<BusinessPurchaseDto?> UpdateAsync(long id, BusinessPurchaseUpsertRequest request, CancellationToken ct = default)
    {
        var entity = await db.business_purchases.FirstOrDefaultAsync(p => p.id == id, ct);
        if (entity is null)
        {
            return null;
        }

        entity.purchase_date = request.PurchaseDate;
        entity.purchase_type = request.PurchaseType.ToString();
        entity.description = request.Description;
        entity.supplier = request.Supplier;
        entity.amount_excl_gst = request.AmountExclGst;
        entity.gst_amount = request.GstAmount;
        entity.is_capital_asset = request.IsCapitalAsset;
        entity.is_trading_stock_purchase = request.IsTradingStockPurchase;
        entity.notes = request.Notes;

        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<bool> DeleteAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.business_purchases.FirstOrDefaultAsync(p => p.id == id, ct);
        if (entity is null)
        {
            return false;
        }

        db.business_purchases.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private static BusinessPurchaseDto ToDto(business_purchase entity) => new()
    {
        Id = entity.id,
        PurchaseDate = entity.purchase_date,
        PurchaseType = Enum.Parse<PurchaseType>(entity.purchase_type),
        Description = entity.description,
        Supplier = entity.supplier,
        AmountExclGst = entity.amount_excl_gst,
        GstAmount = entity.gst_amount,
        IsCapitalAsset = entity.is_capital_asset,
        IsTradingStockPurchase = entity.is_trading_stock_purchase,
        Notes = entity.notes,
    };
}
