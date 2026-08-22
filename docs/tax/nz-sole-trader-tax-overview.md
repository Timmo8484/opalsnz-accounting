# NZ Sole Trader Tax Overview

> General reference only, not tax advice. Confirm current figures against IRD (ird.govt.nz) or with
> your accountant before relying on them, especially rates/thresholds which change over time.

## How sole trader tax works

As a sole trader you and the business are the same legal entity. All business income is reported as
part of your personal income tax return (IR3), regardless of how many income streams you run — in
this case **software development contracting** and **opal cutting/selling** are combined into a single
business income figure. You don't need to separate them for IRD, but this app keeps them tagged
separately so you can see how each stream is performing.

Three separate obligations apply:

1. **Income tax** — tax on your net profit (income minus deductible expenses), paid via the IR3 return,
   typically with provisional tax instalments during the year if your prior year's residual income tax
   was over the threshold.
2. **GST** — a separate consumption tax charged on your sales and claimable on your business
   purchases, filed on its own cycle (see [gst-quick-reference.md](./gst-quick-reference.md)).
3. **ACC levies** — calculated from the same net profit figure as income tax, invoiced separately by
   ACC (see below).

## Balance date

Standard balance date is **31 March** (matches the NZ tax year, 1 April – 31 March). All reports in
this app default to that year unless changed.

## Accounting basis

This app uses **cash basis**: income is recorded when a customer actually pays (invoice paid, opal
sold), and expenses when you actually pay them. This matches how the app's Income List is described
("add income amounts when invoices get paid").

## ACC levies (Work Account)

As a self-employed person you pay ACC levies yourself — there's no employer to deduct them. They fund
the accident compensation scheme and arrive as a separate bill from ACC, but are calculated from the
same net profit figure your income tax is based on, so this app treats them as another line item
against business income rather than a separate module.

- **How it's calculated**: ACC uses your **liable earnings** (essentially your net business profit, up
  to an annual maximum) multiplied by a levy rate that depends on your **classification unit (CU)** —
  the industry code for your work. Software development and opal cutting/polishing likely sit under
  different CUs with different rates; ACC apportions the levy if your earnings split across CUs.
- **Components**: a Work Account levy (varies by CU/industry risk) plus a small flat Working Safer
  levy. (The Earners' levy for non-work injuries is collected via PAYE for employees; self-employed
  people pay the equivalent as part of the same ACC invoice.)
- **Timing**: ACC invoices arrive **after** your tax return is processed — commonly well over a year
  after the income year it relates to — so it lags behind income tax. Worth setting aside a percentage
  of profit as you go so the eventual invoice isn't a surprise.
- **Cover options**: default cover is **CoverPlus** (levy based on actual earnings, invoiced in arrears
  as above); **CoverPlus Extra** lets you fix an agreed level of cover upfront instead.
- **Deductibility**: ACC levies paid for cover on your business earnings are themselves a deductible
  business expense — record them as a normal expense entry and they reduce net profit like any other
  cost.

## What counts as deductible

A cost is deductible if it's incurred in earning your business income and isn't private in nature.
Where a cost is mixed (e.g. home office, a vehicle used for both business and personal use), only the
business-use portion is deductible — see:

- [home-office-expenses.md](./home-office-expenses.md) — apportioning home costs like power, internet,
  mortgage interest.
- [depreciation-cheatsheet.md](./depreciation-cheatsheet.md) — capital purchases like opal-processing
  tools that provide value over more than one year.

Raw opal purchased for resale is a normal revenue expense (cost of materials), not a capital asset.

## Key IRD references

- IR3 — individual income tax return guide
- IR260 — Depreciation, a guide for business
- IR265 — General depreciation rates
- ird.govt.nz/gst — GST guidance
- ird.govt.nz/roles/self-employed — self-employed / sole trader hub
- acc.co.nz — ACC levies for self-employed people, classification units and CoverPlus/CoverPlus Extra

## Related documents

- [gst-quick-reference.md](./gst-quick-reference.md)
- [depreciation-cheatsheet.md](./depreciation-cheatsheet.md)
- [home-office-expenses.md](./home-office-expenses.md)
- [trading-stock-and-startup-assets.md](./trading-stock-and-startup-assets.md)
- [../architecture-decisions.md](../architecture-decisions.md)
