# Plan: Bank Transaction CSV Import

Import an **ANZ** bank CSV export from a mixed personal/business account, suggest which rows
are business income/expenses, and let the user review and approve before they become real
`IncomeEntry` / `BusinessPurchase` / expense records.

ANZ export column layout confirmed from a real sample file:
`Type,Details,Particulars,Code,Reference,Amount,Date,ForeignCurrencyAmount,ConversionCharge`,
with transaction types such as `Eft-Pos`, `Direct Debit`, `Automatic Payment`, `Transfer`,
`Visa Purchase`, `Atm Debit`, `Loan Payment`.

## Decisions

| Topic | Decision |
|---|---|
| Automation level | Suggest-only — rule/keyword matches propose a category + entry type, user must manually approve/edit/reject each row before it's saved as a real record |
| Mobile phone (One NZ) | Maps to the existing "Internet" home-office expense category (not a new category) |
| Merchant seeding | Seed `transaction_mapping_rules` from the opalsnz opal-supplier list (`C:\src\opalsnz\db\opalsnz\sql\V1.0.2__init_opal_parcels.sql`) — 21 supplier names (BOD, 53_Frogs, Solo, Seda_Opal, Red_Velvet, Miner_Mike, Shane_Channing, Ryan_Clare, LR_Opals, Sandra_Bermon, Angel_Opals, J_Sullivan, JandJ, Blacklighters, Dale_Price, Absolute_Opals, Placid_Gems, Ian_Danny, WA_Opals, Scott_McMillan, Coober_Pedy_Opals) |
| Raw file retention | Keep the original uploaded CSV file (stored server-side) linked to its import batch, for audit/re-review |
| Cadence & dedup | Feature will be used on an ongoing basis (not one-off) — re-uploading overlapping date ranges must be deduplicated automatically |

## Data model (new tables, `db/opalsnz_accounting/sql/Vn__bank_import.sql`)

- `bank_import_batches` — id, uploaded_at, original_filename, raw_file_path, row_count.
- `bank_transaction_imports` — id, batch_id FK, raw CSV fields (type, details, particulars, code, reference, amount, txn_date), a SHA-256 **fingerprint** (hash of date+amount+details+reference) for dedup across re-uploads with overlapping ranges, suggested_category/entry_type (nullable), status (Pending/Approved/Rejected), linked_entry_id + linked_entry_type once approved.
- `transaction_mapping_rules` — id, match_text (merchant/keyword), match_type (Contains/Exact), target_entry_type (Income/Expense/BusinessPurchase), target_category_id (nullable FK to expense_categories), seeded from opal supplier list + user-added rules over time.

## GST handling

- ANZ amounts are GST-inclusive gross figures. Add `GstCalculator.SplitInclusiveAmount(decimal gross)` returning `(amountExclGst, gstAmount)` using the existing ×3/23 content formula, reused by the approval step when creating the final `IncomeEntry`/`BusinessPurchase`/expense record.

## Implementation steps

1. **Backend**: migration for the 3 tables above; `BankImportService` (parse CSV, compute fingerprint, apply `transaction_mapping_rules` to produce suggestions, dedupe against existing fingerprints on upload); `BankImportController` with endpoints: upload CSV → batch + parsed rows, list pending rows for review, approve row (creates the real entry via existing Income/Expense/BusinessPurchase services + `SplitInclusiveAmount`), reject row, manage mapping rules (CRUD).
2. **Frontend** (*depends on step 1*): `bank_import_page.dart` + bloc — upload control, review table (suggested category/type editable inline, checkbox approve/reject, bulk-approve for high-confidence matches), mapping-rules management screen.
3. **Tests** (*parallel with step 2*): unit tests for fingerprint generation/dedup, mapping-rule matching, `SplitInclusiveAmount`.
4. **Manual verification** (*depends on 1-3*): upload the real ANZ CSV, confirm known business rows (Genesis Energy Power, council rates/water, opal supplier wires, One NZ mobile) are suggested correctly, confirm re-uploading an overlapping date range produces zero duplicate entries.

## Relevant files

- `db/opalsnz_accounting/sql/Vn__bank_import.sql` — new migration (n = next Flyway version after existing V1/V2).
- `backend/Opalsnz.Accounting.Service/BankImport/BankImportService.cs` — new.
- `backend/Opalsnz.Accounting.Service/Calculators/GstCalculator.cs` — add `SplitInclusiveAmount`.
- `backend/Opalsnz.Accounting.Api/Controllers/BankImportController.cs` — new.
- `frontend/opalsnz_accounting_app/lib/pages/bank_import_page.dart` + corresponding bloc/service files — new.

## Further considerations

1. Mapping rules will misfire on individual-name suppliers/payees that look like personal transactions — mitigated by suggest-only + manual approval, not auto-posting.
2. v1 does not support splitting a single transaction across personal/business (e.g. partially business fuel) — out of scope for now, flag as future enhancement.
3. Recommend the user open a dedicated business bank account going forward to reduce manual triage — a business decision, not a build task.
