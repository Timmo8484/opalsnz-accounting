using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Db.Models;
using Opalsnz.Accounting.Model.Dto;
using Opalsnz.Accounting.Model.Enums;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.Calculators;

namespace Opalsnz.Accounting.Service.Assets;

public interface IAssetService
{
    Task<List<AssetDto>> GetAllAsync(CancellationToken ct = default);
    Task<AssetDto?> GetByIdAsync(long id, CancellationToken ct = default);
    Task<AssetDto> CreateAsync(AssetUpsertRequest request, CancellationToken ct = default);
    Task<AssetDto?> UpdateAsync(long id, AssetUpsertRequest request, CancellationToken ct = default);
    Task<bool> DeleteAsync(long id, CancellationToken ct = default);
}

public class AssetService(AccountingContext db) : IAssetService
{
    public async Task<List<AssetDto>> GetAllAsync(CancellationToken ct = default)
    {
        var entities = await db.assets.AsNoTracking().OrderByDescending(a => a.purchase_date).ToListAsync(ct);
        return entities.Select(ToDto).ToList();
    }

    public async Task<AssetDto?> GetByIdAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.assets.AsNoTracking().FirstOrDefaultAsync(a => a.id == id, ct);
        return entity is null ? null : ToDto(entity);
    }

    public async Task<AssetDto> CreateAsync(AssetUpsertRequest request, CancellationToken ct = default)
    {
        var entity = new asset
        {
            business_purchase_id = request.BusinessPurchaseId,
            description = request.Description,
            purchase_date = request.PurchaseDate,
            cost_excl_gst = request.CostExclGst,
            depreciation_method = request.DepreciationMethod.ToString(),
            depreciation_rate = request.DepreciationRate,
            is_low_value_writeoff = DepreciationCalculator.IsLowValueWriteOff(request.CostExclGst),
            disposal_date = request.DisposalDate,
            disposal_amount = request.DisposalAmount,
            notes = request.Notes,
        };

        db.assets.Add(entity);
        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<AssetDto?> UpdateAsync(long id, AssetUpsertRequest request, CancellationToken ct = default)
    {
        var entity = await db.assets.FirstOrDefaultAsync(a => a.id == id, ct);
        if (entity is null)
        {
            return null;
        }

        entity.business_purchase_id = request.BusinessPurchaseId;
        entity.description = request.Description;
        entity.purchase_date = request.PurchaseDate;
        entity.cost_excl_gst = request.CostExclGst;
        entity.depreciation_method = request.DepreciationMethod.ToString();
        entity.depreciation_rate = request.DepreciationRate;
        entity.is_low_value_writeoff = DepreciationCalculator.IsLowValueWriteOff(request.CostExclGst);
        entity.disposal_date = request.DisposalDate;
        entity.disposal_amount = request.DisposalAmount;
        entity.notes = request.Notes;

        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<bool> DeleteAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.assets.FirstOrDefaultAsync(a => a.id == id, ct);
        if (entity is null)
        {
            return false;
        }

        db.assets.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private static AssetDto ToDto(asset entity) => new()
    {
        Id = entity.id,
        BusinessPurchaseId = entity.business_purchase_id,
        Description = entity.description,
        PurchaseDate = entity.purchase_date,
        CostExclGst = entity.cost_excl_gst,
        DepreciationMethod = Enum.Parse<DepreciationMethod>(entity.depreciation_method),
        DepreciationRate = entity.depreciation_rate,
        IsLowValueWriteoff = entity.is_low_value_writeoff,
        DisposalDate = entity.disposal_date,
        DisposalAmount = entity.disposal_amount,
        Notes = entity.notes,
    };
}
