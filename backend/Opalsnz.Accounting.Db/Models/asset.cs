using System;
using System.Collections.Generic;

namespace Opalsnz.Accounting.Db.Models;

public partial class asset
{
    public long id { get; set; }

    public long? business_purchase_id { get; set; }

    public string description { get; set; } = null!;

    public DateOnly purchase_date { get; set; }

    public decimal cost_excl_gst { get; set; }

    public string depreciation_method { get; set; } = null!;

    public decimal depreciation_rate { get; set; }

    public bool is_low_value_writeoff { get; set; }

    public DateOnly? disposal_date { get; set; }

    public decimal? disposal_amount { get; set; }

    public string? notes { get; set; }

    public DateTime created_at { get; set; }

    public DateTime updated_at { get; set; }

    public virtual ICollection<asset_depreciation_year> asset_depreciation_years { get; set; } = new List<asset_depreciation_year>();

    public virtual business_purchase? business_purchase { get; set; }
}
