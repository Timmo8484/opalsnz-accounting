# Bringing Pre-Business Assets Into the Business (Trading Stock)

> General reference only, not tax advice. This scenario involves a specific, fact-dependent valuation
> question and a meaningful dollar amount (~$50,000) — get this confirmed by an accountant (and
> consider an IRD private ruling) before relying on any figure in a return. Keep every bank statement
> and receipt you have; they're exactly what you'll need to substantiate whatever value is used.

## The scenario

Raw opal rough bought over the last ~3 years, paid for with personal (non-business) funds, before
formally operating as a sole trader — now intended for use as material for the opal cutting/selling
income stream.

Two separate questions apply here, and they matter a lot for how much (if anything) reduces your
taxable income and when:

1. Were those purchases *already* a business activity, even though you hadn't registered/thought of
   yourself as a sole trader yet?
2. Assuming not, what value can the opal rough be brought into the business at now?

## Question 1: was it already a business?

In NZ there's no formal "become a sole trader" registration event that starts your tax obligations —
you're taxed as running a business from whenever your activity actually meets the tests for one
(regularity, intention to make a profit, scale, "badges of trade"), regardless of whether you'd told
IRD or GST-registered yet. Buying opal occasionally as a personal collector/hobbyist is very different
from a pattern of regular purchases with a clear intention to resell — the latter can mean a business
(and associated income tax/GST obligations) already existed in earlier years, which is a separate
conversation with your accountant from the question below. This document assumes the answer is "no, it
was genuinely personal" and covers the clean case of bringing a personal asset into a new business.

## Question 2: what's it "worth" going into the business?

Raw opal rough held for the purpose of being processed and resold is **trading stock**, not a
depreciable capital asset (IRD's definition of trading stock explicitly includes "materials kept to
produce or manufacture trading stock"). Trading stock is taxed differently from a normal expense:

- The **opening value** of trading stock in an income year is a deduction.
- The **closing value** of trading stock in an income year is assessable (added back to income).
- In other words, the cost of stock is deducted *as it's used/sold*, not all at once when purchased —
  this is the standard cost-of-goods-sold mechanic, not a straight $50,000 expense in year one.

### The low-value trading stock concession doesn't apply here

Small traders can skip formal stock valuation (use last year's closing value again, no stocktake) if
sales are under $1.3 million **and** a reasonable estimate of closing stock is under $10,000. At
~$50,000 of opal rough, this concession doesn't apply, so the stock needs a proper valuation each year
end (31 March) using one of IRD's recognised methods (cost, discounted selling price, replacement
price, or market selling value if lower than cost).

### Valuing the *opening* stock when it moves from personal to business use

This is the part that genuinely needs an accountant's sign-off: because you (the individual) and the
sole trader business are the same legal person, there's no arm's-length purchase transaction happening
when the rough "becomes" trading stock — which is different from buying stock from a supplier. Two
positions are possible depending on how the trading stock valuation rules apply to your facts:

- **Original cost** — what you actually paid, which your bank statements substantiate well.
- **Market value at the date it becomes trading stock** — which could be higher or lower than your
  original cost after ~3 years, depending on how opal rough prices have moved.

Which figure IRD expects depends on the specific trading-stock-valuation provisions for stock acquired
other than through an ordinary purchase — this is exactly the kind of detail to confirm with your
accountant rather than assume. Bring your bank statements (proof of cost) either way.

## Practical steps

1. Get an accountant to confirm: (a) whether prior years' buying already amounted to a business, and
   (b) whether opening value should be cost or market value.
2. Once confirmed, record a one-off **opening trading stock** figure as at the date the business
   started (not a lump-sum expense entry).
3. From then on, the app needs a stock value at each 31 March (opening = last year's closing) so the
   deductible cost is calculated correctly, rather than only logging raw purchases as expenses.

## App data model — trading stock register

Uses the **periodic method** IRD's opening/closing mechanism is built around (a single stock value at
each year end), not per-stone cost-of-goods-sold matching against individual sales — much simpler while
still meeting the valuation requirement.

- **`TradingStockYear`** — one record per tax year (1 Apr – 31 Mar):
  - `OpeningValue` — first year: the confirmed pre-business value (cost or market value, per your
    accountant); later years: copied from the prior year's `ClosingValue`.
  - `OpeningValueMethod` — `Cost` / `MarketValue` / `PriorYearClosing`.
  - `ClosingValue` — entered at year end using one of IRD's methods (cost, discounted selling price,
    replacement price, or market selling value if lower than cost).
  - `ClosingValueMethod`, `IsFinalised`, `Notes` (e.g. "opening value confirmed by [accountant] on
    [date], based on cost per bank statements").
  - **Deductible stock cost for the year** = `OpeningValue` + (this year's trading-stock purchases) −
    `ClosingValue`. Shown on the annual Reports summary alongside other deductions.
- **`BusinessPurchase.IsTradingStockPurchase`** — flags opal rough purchases so they roll up into "this
  year's trading-stock purchases" for the calculation above. No other change to how purchases are
  entered.
- **`HistoricalStockPurchase`** — optional, record-keeping only: lets you log the individual ~3 years of
  pre-business bank-statement purchases (date, description, amount) as supporting evidence for the
  opening value, without those line items feeding into any tax calculation themselves (only the single
  confirmed `OpeningValue` does).

## Related documents

- [nz-sole-trader-tax-overview.md](./nz-sole-trader-tax-overview.md)
- [../architecture-decisions.md](../architecture-decisions.md)
- [../../plan.md](../../plan.md)
