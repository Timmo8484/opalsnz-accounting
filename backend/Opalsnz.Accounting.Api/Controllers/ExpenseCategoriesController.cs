using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.HomeOfficeExpenses;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/expense-categories")]
public class ExpenseCategoriesController(IExpenseCategoryService categoryService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] bool includeInactive, CancellationToken ct)
        => Ok(await categoryService.GetAllAsync(includeInactive, ct));

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken ct)
    {
        var category = await categoryService.GetByIdAsync(id, ct);
        return category is null ? NotFound() : Ok(category);
    }

    [HttpPost]
    public async Task<IActionResult> Create(ExpenseCategoryUpsertRequest request, CancellationToken ct)
    {
        var created = await categoryService.CreateAsync(request, ct);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:long}")]
    public async Task<IActionResult> Update(long id, ExpenseCategoryUpsertRequest request, CancellationToken ct)
    {
        var updated = await categoryService.UpdateAsync(id, request, ct);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken ct)
        => await categoryService.DeleteAsync(id, ct) ? NoContent() : NotFound();
}
