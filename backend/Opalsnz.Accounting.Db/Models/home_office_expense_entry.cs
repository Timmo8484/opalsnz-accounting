using System;
using System.Collections.Generic;

namespace Opalsnz.Accounting.Db.Models;

public partial class home_office_expense_entry
{
    public long id { get; set; }

    public long expense_category_id { get; set; }

    public DateOnly entry_date { get; set; }

    public decimal gross_amount { get; set; }

    public decimal claim_percent { get; set; }

    public bool has_gst { get; set; }

    public decimal claimable_amount { get; set; }

    public decimal claimable_gst { get; set; }

    public string? notes { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public virtual expense_category expense_category { get; set; } = null!;
}
