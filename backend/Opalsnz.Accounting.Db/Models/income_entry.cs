using System;
using System.Collections.Generic;

namespace Opalsnz.Accounting.Db.Models;

public partial class income_entry
{
    public long id { get; set; }

    public string income_stream { get; set; } = null!;

    public DateOnly entry_date { get; set; }

    public string description { get; set; } = null!;

    public string? invoice_reference { get; set; }

    public decimal amount_excl_gst { get; set; }

    public decimal gst_amount { get; set; }

    public decimal total_amount { get; set; }

    public string? notes { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }
}
