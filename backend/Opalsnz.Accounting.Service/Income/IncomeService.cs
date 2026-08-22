using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Db.Models;
using Opalsnz.Accounting.Model.Dto;
using Opalsnz.Accounting.Model.Enums;
using Opalsnz.Accounting.Model.Requests;

namespace Opalsnz.Accounting.Service.Income;

public interface IIncomeService
{
    Task<List<IncomeEntryDto>> GetAllAsync(DateOnly? fromDate, DateOnly? toDate, CancellationToken ct = default);
    Task<IncomeEntryDto?> GetByIdAsync(long id, CancellationToken ct = default);
    Task<IncomeEntryDto> CreateAsync(IncomeEntryUpsertRequest request, CancellationToken ct = default);
    Task<IncomeEntryDto?> UpdateAsync(long id, IncomeEntryUpsertRequest request, CancellationToken ct = default);
    Task<bool> DeleteAsync(long id, CancellationToken ct = default);
}

public class IncomeService(AccountingContext db) : IIncomeService
{
    public async Task<List<IncomeEntryDto>> GetAllAsync(DateOnly? fromDate, DateOnly? toDate, CancellationToken ct = default)
    {
        var query = db.income_entries.AsNoTracking().AsQueryable();
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

    public async Task<IncomeEntryDto?> GetByIdAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.income_entries.AsNoTracking().FirstOrDefaultAsync(e => e.id == id, ct);
        return entity is null ? null : ToDto(entity);
    }

    public async Task<IncomeEntryDto> CreateAsync(IncomeEntryUpsertRequest request, CancellationToken ct = default)
    {
        var entity = new income_entry
        {
            income_stream = request.IncomeStream.ToString(),
            entry_date = request.EntryDate,
            description = request.Description,
            invoice_reference = request.InvoiceReference,
            amount_excl_gst = request.AmountExclGst,
            gst_amount = request.GstAmount,
            total_amount = request.AmountExclGst + request.GstAmount,
            notes = request.Notes,
        };

        db.income_entries.Add(entity);
        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<IncomeEntryDto?> UpdateAsync(long id, IncomeEntryUpsertRequest request, CancellationToken ct = default)
    {
        var entity = await db.income_entries.FirstOrDefaultAsync(e => e.id == id, ct);
        if (entity is null)
        {
            return null;
        }

        entity.income_stream = request.IncomeStream.ToString();
        entity.entry_date = request.EntryDate;
        entity.description = request.Description;
        entity.invoice_reference = request.InvoiceReference;
        entity.amount_excl_gst = request.AmountExclGst;
        entity.gst_amount = request.GstAmount;
        entity.total_amount = request.AmountExclGst + request.GstAmount;
        entity.notes = request.Notes;

        await db.SaveChangesAsync(ct);
        return ToDto(entity);
    }

    public async Task<bool> DeleteAsync(long id, CancellationToken ct = default)
    {
        var entity = await db.income_entries.FirstOrDefaultAsync(e => e.id == id, ct);
        if (entity is null)
        {
            return false;
        }

        db.income_entries.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private static IncomeEntryDto ToDto(income_entry entity) => new()
    {
        Id = entity.id,
        IncomeStream = Enum.Parse<IncomeStream>(entity.income_stream),
        EntryDate = entity.entry_date,
        Description = entity.description,
        InvoiceReference = entity.invoice_reference,
        AmountExclGst = entity.amount_excl_gst,
        GstAmount = entity.gst_amount,
        TotalAmount = entity.total_amount,
        Notes = entity.notes,
    };
}
