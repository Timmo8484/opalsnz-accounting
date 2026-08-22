using System;
using System.Collections.Generic;

namespace Opalsnz.Accounting.Db.Models;

public partial class trading_stock_year
{
    public long id { get; set; }

    public DateOnly tax_year_start { get; set; }

    public DateOnly tax_year_end { get; set; }

    public decimal opening_value { get; set; }

    public string opening_value_method { get; set; } = null!;

    public decimal? closing_value { get; set; }

    public string? closing_value_method { get; set; }

    public bool is_finalised { get; set; }

    public string? notes { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }
}
