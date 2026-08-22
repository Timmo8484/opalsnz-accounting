using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Db.Models;
using Opalsnz.Accounting.Model.Dto;
using Opalsnz.Accounting.Model.Requests;
using Opalsnz.Accounting.Service.Calculators;

namespace Opalsnz.Accounting.Service.HomeOfficeExpenses;

public interface IHomeOfficeExpenseService
{
    Task<List<HomeOfficeExpenseEntryDto>> GetAllAsync(DateOnly? fromDate, DateOnly? toDate, CancellationToken ct = default);
    Task<HomeOfficeExpenseEntryDto?> GetByIdAsync(long id, CancellationToken ct = default);
    Task<HomeOfficeExpenseEntryDto?> CreateAsync(HomeOfficeExpenseEntryUpsertRequest request, CancellationToken ct = default);
    Task<HomeOfficeExpenseEntryDto?> UpdateAsync(long id, HomeOfficeExpenseEntryUpsertRequest request, CancellationToken ct = default);
    Task<bool> DeleteAsync(long id, CancellationToken ct = default);
}

// Claim % / HasGst are snapshotted onto the entry at creation time (from the category's current
// defaults, unless overridden) so editing a category later doesn't silently change past entries.
public class HomeOfficeExpenseService(AccountingContext db) : IHomeOfficeExpenseService
{
    public async Task<List<HomeOfficeExpenseEntryDto>> GetAllAsync(DateOnly? fromDate, DateOnly? toDate, CancellationToken ct = default)
    {
        var query = db.home_office_expense_entries.AsNoTracking().Include(e => e.expense_category).AsQueryable();
        if (fromDate is not null)
        {
            query = query.Where(e => e.entry_date >= fromDate);
        }
        if (toDate is not null)
        {
            query = query.Where(e => e.entry_date <= toDate);
        }

        var entities = await query.OrderByDescending(e => e.entry_date).ToListAsync(ct);
        return entities.Select(ToDto).ToList();
    }

    public async Task<HomeOfficeExpenseEntryDto?> GetByIdAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.home_office_expense_entries.AsNoTracking()
            .Include(e => e.expense_category)
            .FirstOrDefaultAsync(e => e.id == id, ct);
        return entity is null ? null : ToDto(entity);
    }

    public async Task<HomeOfficeExpenseEntryDto?> CreateAsync(HomeOfficeExpenseEntryUpsertRequest request, CancellationToken ct = default)
    {
        var category = await db.expense_categories.FirstOrDefaultAsync(c => c.id == request.ExpenseCategoryId, ct);
        if (category is null)
        {
            return null;
        }

        var claimPercent = request.ClaimPercent ?? category.default_claim_percent;
        var hasGst = request.HasGst ?? category.has_gst ?? true;
        var claimableAmount = HomeOfficeClaimCalculator.CalculateClaimableAmount(request.GrossAmount, claimPercent);

        var entity = new home_office_expense_entry
        {
            expense_category_id = request.ExpenseCategoryId,
            entry_date = request.EntryDate,
            gross_amount = request.GrossAmount,
            claim_percent = claimPercent,
            has_gst = hasGst,
            claimable_amount = claimableAmount,
            claimable_gst = HomeOfficeClaimCalculator.CalculateClaimableGst(claimableAmount, hasGst),
            notes = request.Notes,
        };

        db.home_office_expense_entries.Add(entity);
        await db.SaveChangesAsync(ct);
        entity.expense_category = category;
        return ToDto(entity);
    }

    public async Task<HomeOfficeExpenseEntryDto?> UpdateAsync(long id, HomeOfficeExpenseEntryUpsertRequest request, CancellationToken ct = default)
    {
        var entity = await db.home_office_expense_entries.Include(e => e.expense_category).FirstOrDefaultAsync(e => e.id == id, ct);
        if (entity is null)
        {
            return null;
        }

        var category = entity.expense_category_id == request.ExpenseCategoryId
            ? entity.expense_category
            : await db.expense_categories.FirstOrDefaultAsync(c => c.id == request.ExpenseCategoryId, ct);
        if (category is null)
        {
            return null;
        }

        var claimPercent = request.ClaimPercent ?? category.default_claim_percent;
        var hasGst = request.HasGst ?? category.has_gst ?? true;
        var claimableAmount = HomeOfficeClaimCalculator.CalculateClaimableAmount(request.GrossAmount, claimPercent);

        entity.expense_category_id = request.ExpenseCategoryId;
        entity.expense_category = category;
        entity.entry_date = request.EntryDate;
        entity.gross_amount = request.GrossAmount;
        entity.claim_percent = claimPercent;
        entity.has_gst = hasGst;
        entity.claimable_amount = claimableAmount;
        entity.claimable_gst = HomeOfficeClaimCalculator.CalculateClaimableGst(claimableAmount, hasGst);
        entity.notes = request.Notes;

        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<bool> DeleteAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.home_office_expense_entries.FirstOrDefaultAsync(e => e.id == id, ct);
        if (entity is null)
        {
            return false;
        }

        db.home_office_expense_entries.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private static HomeOfficeExpenseEntryDto ToDto(home_office_expense_entry entity) => new()
    {
        Id = entity.id,
        ExpenseCategoryId = entity.expense_category_id,
        ExpenseCategoryName = entity.expense_category?.name ?? string.Empty,
        EntryDate = entity.entry_date,
        GrossAmount = entity.gross_amount,
        ClaimPercent = entity.claim_percent,
        HasGst = entity.has_gst,
        ClaimableAmount = entity.claimable_amount,
        ClaimableGst = entity.claimable_gst,
        Notes = entity.notes,
    };
}
