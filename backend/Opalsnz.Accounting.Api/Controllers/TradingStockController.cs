using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.TradingStock;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/trading-stock-years")]
public class TradingStockController(ITradingStockService tradingStockService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct) => Ok(await tradingStockService.GetAllAsync(ct));

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken ct)
    {
        var year = await tradingStockService.GetByIdAsync(id, ct);
        return year is null ? NotFound() : Ok(year);
    }

    [HttpPost]
    public async Task<IActionResult> Create(TradingStockYearUpsertRequest request, CancellationToken ct)
    {
        try
        {
            var created = await tradingStockService.CreateAsync(request, ct);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpPut("{id:long}")]
    public async Task<IActionResult> Update(long id, TradingStockYearUpsertRequest request, CancellationToken ct)
    {
        try
        {
            var updated = await tradingStockService.UpdateAsync(id, request, ct);
            return updated is null ? NotFound() : Ok(updated);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken ct)
        => await tradingStockService.DeleteAsync(id, ct) ? NoContent() : NotFound();
}
