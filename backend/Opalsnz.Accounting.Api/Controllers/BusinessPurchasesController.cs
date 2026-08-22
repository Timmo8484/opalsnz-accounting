using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.BusinessPurchases;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/business-purchases")]
public class BusinessPurchasesController(IBusinessPurchaseService purchaseService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] DateOnly? fromDate, [FromQuery] DateOnly? toDate, CancellationToken ct)
        => Ok(await purchaseService.GetAllAsync(fromDate, toDate, ct));

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken ct)
    {
        var purchase = await purchaseService.GetByIdAsync(id, ct);
        return purchase is null ? NotFound() : Ok(purchase);
    }

    [HttpPost]
    public async Task<IActionResult> Create(BusinessPurchaseUpsertRequest request, CancellationToken ct)
    {
        var created = await purchaseService.CreateAsync(request, ct);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:long}")]
    public async Task<IActionResult> Update(long id, BusinessPurchaseUpsertRequest request, CancellationToken ct)
    {
        var updated = await purchaseService.UpdateAsync(id, request, ct);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken ct)
        => await purchaseService.DeleteAsync(id, ct) ? NoContent() : NotFound();
}
