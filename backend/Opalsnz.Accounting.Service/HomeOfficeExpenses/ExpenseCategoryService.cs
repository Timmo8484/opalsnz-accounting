using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Db.Models;
using Opalsnz.Accounting.Model.Dto;
using Opalsnz.Accounting.Model.Requests;

namespace Opalsnz.Accounting.Service.HomeOfficeExpenses;

public interface IExpenseCategoryService
{
    Task<List<ExpenseCategoryDto>> GetAllAsync(bool includeInactive, CancellationToken ct = default);
    Task<ExpenseCategoryDto?> GetByIdAsync(long id, CancellationToken ct = default);
    Task<ExpenseCategoryDto> CreateAsync(ExpenseCategoryUpsertRequest request, CancellationToken ct = default);
    Task<ExpenseCategoryDto?> UpdateAsync(long id, ExpenseCategoryUpsertRequest request, CancellationToken ct = default);
    Task<bool> DeleteAsync(long id, CancellationToken ct = default);
}

public class ExpenseCategoryService(AccountingContext db) : IExpenseCategoryService
{
    public async Task<List<ExpenseCategoryDto>> GetAllAsync(bool includeInactive, CancellationToken ct = default)
    {
        var query = db.expense_categories.AsNoTracking().AsQueryable();
        if (!includeInactive)
        {
            query = query.Where(c => c.is_active == true);
        }

        var entities = await query.OrderBy(c => c.name).ToListAsync(ct);
        return entities.Select(ToDto).ToList();
    }

    public async Task<ExpenseCategoryDto?> GetByIdAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.expense_categories.AsNoTracking().FirstOrDefaultAsync(c => c.id == id, ct);
        return entity is null ? null : ToDto(entity);
    }

    public async Task<ExpenseCategoryDto> CreateAsync(ExpenseCategoryUpsertRequest request, CancellationToken ct = default)
    {
        var entity = new expense_category
        {
            name = request.Name,
            default_claim_percent = request.DefaultClaimPercent,
            has_gst = request.HasGst,
            is_active = request.IsActive,
        };

        db.expense_categories.Add(entity);
        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<ExpenseCategoryDto?> UpdateAsync(long id, ExpenseCategoryUpsertRequest request, CancellationToken ct = default)
    {
        var entity = await db.expense_categories.FirstOrDefaultAsync(c => c.id == id, ct);
        if (entity is null)
        {
            return null;
        }

        entity.name = request.Name;
        entity.default_claim_percent = request.DefaultClaimPercent;
        entity.has_gst = request.HasGst;
        entity.is_active = request.IsActive;

        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<bool> DeleteAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.expense_categories.FirstOrDefaultAsync(c => c.id == id, ct);
        if (entity is null)
        {
            return false;
        }

        db.expense_categories.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private static ExpenseCategoryDto ToDto(expense_category entity) => new()
    {
        Id = entity.id,
        Name = entity.name,
        DefaultClaimPercent = entity.default_claim_percent,
        HasGst = entity.has_gst ?? true,
        IsActive = entity.is_active ?? true,
    };
}
