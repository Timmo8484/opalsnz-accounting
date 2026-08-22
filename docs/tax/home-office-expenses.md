# Home Office Expenses

> General reference only, not tax advice. Confirm your chosen percentages are reasonable and
> defensible (e.g. based on floor area and/or time-in-use) with your accountant.

## Method used in this app

IRD allows either a published square-metre rate method, or apportioning actual costs by a reasonable
business-use percentage. This app uses the **actual cost method with a fixed, user-editable percentage
per expense category** — you decide the % once per category (e.g. based on the floor area of your
office/workshop vs the whole house), and can update it later if circumstances change (e.g. you convert
more of the house to workshop space).

## Example categories & percentages

| Category | Example % | Has GST? | Notes |
|---|---|---|---|
| Mortgage interest | 25% | No | Interest only — principal repayments are never deductible |
| Power | 50% | Yes | |
| Internet | 50% | Yes | |
| Rates | e.g. 25% | No | Council rates are GST-exempt |
| Home/contents insurance | e.g. 25% | Usually yes | |

These are just examples matching what you described — actual % values are configurable per category
in Settings, not hardcoded.

## Claimable amount calculation

For each expense entry:

$$
\text{Claimable amount} = \text{gross cost} \times \text{category claim \%}
$$

If the category has GST and you're GST registered, the input GST you can claim on that entry is:

$$
\text{Claimable GST} = \text{claimable amount} \times \frac{3}{23}
$$

(GST is calculated **after** apportionment — i.e. on the claimable/business-use portion, not the full
bill.)

## Worked examples

- **Power bill** $220 (GST-inclusive) at 50% claim: claimable amount = $110. GST claimable within that
  = $110 × 3/23 = $14.35.
- **Mortgage interest** $1,200 for the period at 25% claim: claimable amount = $300. No GST claimable
  (financial services are GST-exempt).

## What the app tracks

- `ExpenseCategory`: name, default claim %, whether the category typically has GST.
- `HomeOfficeExpenseEntry`: date, category, gross amount, claim % (snapshot from the category at entry
  time, editable per entry), computed claimable amount and claimable GST.

Snapshotting the % per entry means changing a category's default % later doesn't silently alter past
entries.

## Related documents

- [nz-sole-trader-tax-overview.md](./nz-sole-trader-tax-overview.md)
- [gst-quick-reference.md](./gst-quick-reference.md)
