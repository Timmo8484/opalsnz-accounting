# SQL migrations

Flyway SQL migrations for the `opalsnz_accounting` schema live in this folder.

Naming: `V<version>__<description>.sql`, applied in order. Never edit an already-applied migration —
add a new `Vn` file instead. After adding a migration, regenerate the EF Core models with
`../../backend/Opalsnz.Accounting.Db/scaffold-db.ps1`.
