# GST Quick Reference

> General reference only, not tax advice. Confirm current rates/thresholds with IRD or your accountant.

## Basics

- GST rate: **15%**.
- You're GST registered and file **two-monthly (bi-monthly)** returns.
- Registration is compulsory once turnover exceeds (or is expected to exceed) $60,000 in a 12-month
  period; below that it's voluntary — noted here for context, not relevant since you're already
  registered.

## GST content formula

Given a GST-inclusive amount, the GST component is:

$$
GST = \text{amount} \times \frac{3}{23}
$$

(because $15/115 = 3/23$). The GST-exclusive amount is $\text{amount} \times \frac{20}{23}$.

Example: a $115 power bill (GST-inclusive) contains $115 \times 3/23 = \$15$ GST.

## Output GST vs input GST

- **Output GST** — GST you charge/collect on sales (income). If your software dev and opal sales
  prices are GST-inclusive, the output GST is the 3/23 portion of each sale.
- **Input GST** — GST you can claim back on business purchases and apportioned home-office costs,
  provided the supply itself includes GST (see below) and you hold valid taxable supply information
  for the purchase.
- **Net GST** for a period = output GST − input GST. Positive = pay IRD; negative = refund.

## What does and doesn't include GST

| Cost type | Has GST? | Notes |
|---|---|---|
| Power, internet, phone | Yes | Standard taxable supplies |
| General/contents/fire insurance | Usually yes | Life/health insurance is exempt |
| Rates (council) | No | Exempt supply |
| Mortgage interest | No | Financial services are GST-exempt |
| Rent (residential) | No | Exempt supply |
| Raw opal purchases, tools, equipment | Yes (if bought from a GST-registered NZ supplier) | No GST if bought from a non-registered private seller or overseas without GST charged |

Only claim the input GST portion on costs that actually carry GST — home office apportionment still
applies first, then GST is calculated on the apportioned (claimable) amount, not the full bill.

## Filing periods & due dates

Two-monthly periods, return + payment due on the **28th of the month following period end** (with the
January and May due dates extended to the 7th of the following month).

## Record-keeping

Since the April 2023 invoicing reform, IRD requires **taxable supply information** (TSI) rather than a
formal "tax invoice" — the specific detail required scales with the amount:

- Supplies **$200 or less**: minimal info (supplier name, date, description, amount) is enough.
- Supplies **over $200**: fuller TSI is needed (GST number, buyer/seller details, description,
  amount/GST charged).

Keep receipts/invoices for all claimed purchases regardless — the app should let you attach a
reference/note to each entry.

## Related documents

- [nz-sole-trader-tax-overview.md](./nz-sole-trader-tax-overview.md)
- [home-office-expenses.md](./home-office-expenses.md)
- [depreciation-cheatsheet.md](./depreciation-cheatsheet.md)
