using System;
using System.Collections.Generic;

namespace Opalsnz.Accounting.Db.Models;

public partial class historical_stock_purchase
{
    public long id { get; set; }

    public DateOnly purchase_date { get; set; }

    public string description { get; set; } = null!;

    public decimal amount { get; set; }

    public string? notes { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }
}
