using System;
using System.Collections.Generic;

namespace Opalsnz.Accounting.Db.Models;

public partial class expense_category
{
    public long id { get; set; }

    public string name { get; set; } = null!;

    public decimal default_claim_percent { get; set; }

    public bool? has_gst { get; set; }

    public bool? is_active { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public virtual ICollection<home_office_expense_entry> home_office_expense_entries { get; set; } = new List<home_office_expense_entry>();
}
