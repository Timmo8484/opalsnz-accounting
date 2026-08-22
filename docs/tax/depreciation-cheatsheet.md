# Depreciation Cheatsheet

> General reference only, not tax advice. Confirm current rates/thresholds against IRD's IR265
> "General depreciation rates" guide or with your accountant — rates and the low-value threshold have
> changed before and may change again.

## When something needs to be depreciated

- **Revenue expense** — day-to-day running costs (raw opal stock, stationery, small consumables) — 
  fully deductible in the year paid, no depreciation involved.
- **Capital asset** — something kept and used for longer than a year (lapidary saws, grinders,
  polishing units, cabbing machines, computers) — deduct its cost over time as depreciation, not all at
  once.

## Low-value asset threshold

Capital assets costing **$1,000 or less (excl. GST)** can be expensed in full in the year of purchase
instead of being depreciated. This has applied since 17 March 2021. (There was a temporary COVID-era
threshold of $5,000 for assets bought 17 Mar 2020 – 16 Mar 2021 — not relevant now, noted for
historical context only.)

Assets **over $1,000** must go on the asset register and be depreciated using an IRD rate.

## Depreciation methods

IRD publishes both a diminishing value (DV) and a straight line (SL) rate for each asset category in
IR265. Pick one method per asset when you first depreciate it.

### Diminishing value (DV)

$$
\text{Depreciation this year} = \text{opening book value} \times \text{DV rate}
$$

Book value reduces each year, so the deduction gets smaller each year. Book value can't go below zero
(or below any residual/salvage value you've set).

### Straight line (SL)

$$
\text{Depreciation this year} = \text{original cost} \times \text{SL rate}
$$

Same dollar deduction every year until the asset is fully written off.

### Part-year ownership

If an asset is bought partway through the tax year, apportion the year's depreciation by the number of
months (or days) owned during the year:

$$
\text{Depreciation} = \text{full-year amount} \times \frac{\text{months owned}}{12}
$$

## Worked example

A cabbing machine bought for $2,400 (excl. GST) on 1 October (6 months into a 31 March year-end),
depreciated using DV at a 20% rate:

- Year 1 (6/12 months): $2,400 \times 20\% \times 6/12 = \$240$. Closing book value: $2,160.
- Year 2 (full year): $2,160 \times 20\% = \$432$. Closing book value: $1,728.
- ...continues until book value approaches zero.

## What the app tracks per asset

- Purchase date, description, cost (excl. GST), method (DV/SL), rate.
- One `AssetDepreciationYear` row per tax year: opening value, depreciation amount, closing value.
- A flag for assets ≤$1,000 so they're expensed immediately instead of depreciated.

## Related documents

- [nz-sole-trader-tax-overview.md](./nz-sole-trader-tax-overview.md)
- [gst-quick-reference.md](./gst-quick-reference.md)
