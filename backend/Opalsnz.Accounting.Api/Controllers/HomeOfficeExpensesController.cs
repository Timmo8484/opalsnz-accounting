using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.HomeOfficeExpenses;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/home-office-expenses")]
public class HomeOfficeExpensesController(IHomeOfficeExpenseService expenseService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] DateOnly? fromDate, [FromQuery] DateOnly? toDate, CancellationToken ct)
        => Ok(await expenseService.GetAllAsync(fromDate, toDate, ct));

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken ct)
    {
        var entry = await expenseService.GetByIdAsync(id, ct);
        return entry is null ? NotFound() : Ok(entry);
    }

    [HttpPost]
    public async Task<IActionResult> Create(HomeOfficeExpenseEntryUpsertRequest request, CancellationToken ct)
    {
        var created = await expenseService.CreateAsync(request, ct);
        return created is null ? BadRequest("Unknown expense category.") : CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:long}")]
    public async Task<IActionResult> Update(long id, HomeOfficeExpenseEntryUpsertRequest request, CancellationToken ct)
    {
        var updated = await expenseService.UpdateAsync(id, request, ct);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken ct)
        => await expenseService.DeleteAsync(id, ct) ? NoContent() : NotFound();
}
