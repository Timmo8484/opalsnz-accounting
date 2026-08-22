using System;
using System.Collections.Generic;

namespace Opalsnz.Accounting.Db.Models;

public partial class asset_depreciation_year
{
    public long id { get; set; }

    public long asset_id { get; set; }

    public DateOnly tax_year_start { get; set; }

    public DateOnly tax_year_end { get; set; }

    public decimal opening_value { get; set; }

    public decimal depreciation_amount { get; set; }

    public decimal closing_value { get; set; }

    public sbyte months_owned_this_year { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public virtual asset asset { get; set; } = null!;
}
