using System;
using System.Collections.Generic;

namespace Opalsnz.Accounting.Db.Models;

public partial class business_purchase
{
    public long id { get; set; }

    public DateOnly purchase_date { get; set; }

    public string purchase_type { get; set; } = null!;

    public string description { get; set; } = null!;

    public string? supplier { get; set; }

    public decimal amount_excl_gst { get; set; }

    public decimal gst_amount { get; set; }

    public bool is_capital_asset { get; set; }

    public bool is_trading_stock_purchase { get; set; }

    public string? notes { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public virtual ICollection<asset> assets { get; set; } = new List<asset>();
}
