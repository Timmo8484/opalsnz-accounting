using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.Assets;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/assets")]
public class AssetsController(IAssetService assetService, IAssetDepreciationService depreciationService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct) => Ok(await assetService.GetAllAsync(ct));

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken ct)
    {
        var asset = await assetService.GetByIdAsync(id, ct);
        return asset is null ? NotFound() : Ok(asset);
    }

    [HttpPost]
    public async Task<IActionResult> Create(AssetUpsertRequest request, CancellationToken ct)
    {
        var created = await assetService.CreateAsync(request, ct);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:long}")]
    public async Task<IActionResult> Update(long id, AssetUpsertRequest request, CancellationToken ct)
    {
        var updated = await assetService.UpdateAsync(id, request, ct);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken ct)
        => await assetService.DeleteAsync(id, ct) ? NoContent() : NotFound();

    [HttpGet("{id:long}/depreciation-years")]
    public async Task<IActionResult> GetDepreciationYears(long id, CancellationToken ct)
        => Ok(await depreciationService.GetForAssetAsync(id, ct));

    [HttpPost("depreciation-years")]
    public async Task<IActionResult> CreateDepreciationYear(AssetDepreciationYearUpsertRequest request, CancellationToken ct)
    {
        var created = await depreciationService.CreateYearAsync(request, ct);
        return created is null ? NotFound("Unknown asset.") : Ok(created);
    }
}
