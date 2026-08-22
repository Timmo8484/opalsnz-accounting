namespace Opalsnz.Accounting.Model.Enums;

// How a TradingStockYear's OpeningValue was determined - see docs/tax/trading-stock-and-startup-assets.md.
public enum OpeningValueMethod
{
    Cost,
    MarketValue,
    PriorYearClosing,
}
