using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Db.Models;
using Opalsnz.Accounting.Model.Dto;
using Opalsnz.Accounting.Model.Enums;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.Calculators;

namespace Opalsnz.Accounting.Service.Assets;

public interface IAssetDepreciationService
{
    Task<List<AssetDepreciationYearDto>> GetForAssetAsync(long assetId, CancellationToken ct = default);

    // Opening value = the asset's cost (first year) or the prior tax year's closing value; the
    // depreciation amount and closing value are always calculated, never supplied by the caller.
    Task<AssetDepreciationYearDto?> CreateYearAsync(AssetDepreciationYearUpsertRequest request, CancellationToken ct = default);
}

public class AssetDepreciationService(AccountingContext db) : IAssetDepreciationService
{
    public async Task<List<AssetDepreciationYearDto>> GetForAssetAsync(long assetId, CancellationToken ct = default)
    {
        var entities = await db.asset_depreciation_years.AsNoTracking()
            .Where(y => y.asset_id == assetId)
            .OrderBy(y => y.tax_year_start)
            .ToListAsync(ct);
        return entities.Select(ToDto).ToList();
    }

    public async Task<AssetDepreciationYearDto?> CreateYearAsync(AssetDepreciationYearUpsertRequest request, CancellationToken ct = default)
    {
        var asset = await db.assets.FirstOrDefaultAsync(a => a.id == request.AssetId, ct);
        if (asset is null)
        {
            return null;
        }

        var priorYear = await db.asset_depreciation_years
            .Where(y => y.asset_id == request.AssetId && y.tax_year_start < request.TaxYearStart)
            .OrderByDescending(y => y.tax_year_start)
            .FirstOrDefaultAsync(ct);

        var openingValue = priorYear?.closing_value ?? asset.cost_excl_gst;
        var depreciationAmount = DepreciationCalculator.CalculateDepreciation(
            Enum.Parse<DepreciationMethod>(asset.depreciation_method),
            asset.cost_excl_gst,
            openingValue,
            asset.depreciation_rate,
            request.MonthsOwnedThisYear);

        var entity = new asset_depreciation_year
        {
            asset_id = request.AssetId,
            tax_year_start = request.TaxYearStart,
            tax_year_end = request.TaxYearEnd,
            opening_value = openingValue,
            depreciation_amount = depreciationAmount,
            closing_value = openingValue - depreciationAmount,
            months_owned_this_year = (sbyte)request.MonthsOwnedThisYear,
        };

        db.asset_depreciation_years.Add(entity);
        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    private static AssetDepreciationYearDto ToDto(asset_depreciation_year entity) => new()
    {
        Id = entity.id,
        AssetId = entity.asset_id,
        TaxYearStart = entity.tax_year_start,
        TaxYearEnd = entity.tax_year_end,
        OpeningValue = entity.opening_value,
        DepreciationAmount = entity.depreciation_amount,
        ClosingValue = entity.closing_value,
        MonthsOwnedThisYear = entity.months_owned_this_year,
    };
}
