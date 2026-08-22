using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.TradingStock;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/historical-stock-purchases")]
public class HistoricalStockPurchasesController(IHistoricalStockPurchaseService historyService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct) => Ok(await historyService.GetAllAsync(ct));

    [HttpPost]
    public async Task<IActionResult> Create(HistoricalStockPurchaseUpsertRequest request, CancellationToken ct)
        => Ok(await historyService.CreateAsync(request, ct));

    [HttpPut("{id:long}")]
    public async Task<IActionResult> Update(long id, HistoricalStockPurchaseUpsertRequest request, CancellationToken ct)
    {
        var updated = await historyService.UpdateAsync(id, request, ct);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken ct)
        => await historyService.DeleteAsync(id, ct) ? NoContent() : NotFound();
}
