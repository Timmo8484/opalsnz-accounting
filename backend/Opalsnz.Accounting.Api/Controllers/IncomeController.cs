using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.Income;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class IncomeController(IIncomeService incomeService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] DateOnly? fromDate, [FromQuery] DateOnly? toDate, CancellationToken ct)
        => Ok(await incomeService.GetAllAsync(fromDate, toDate, ct));

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken ct)
    {
        var entry = await incomeService.GetByIdAsync(id, ct);
        return entry is null ? NotFound() : Ok(entry);
    }

    [HttpPost]
    public async Task<IActionResult> Create(IncomeEntryUpsertRequest request, CancellationToken ct)
    {
        var created = await incomeService.CreateAsync(request, ct);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:long}")]
    public async Task<IActionResult> Update(long id, IncomeEntryUpsertRequest request, CancellationToken ct)
    {
        var updated = await incomeService.UpdateAsync(id, request, ct);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken ct)
        => await incomeService.DeleteAsync(id, ct) ? NoContent() : NotFound();
}
