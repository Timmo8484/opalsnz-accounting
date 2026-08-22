using Microsoft.EntityFrameworkCore;

namespace Opalsnz.Accounting.Db;

// Models are scaffolded from the MySQL schema (Flyway-managed SQL migrations own the schema, this
// context is regenerated from it) - see scaffold-db.ps1. DbSets are added as Phase 3 introduces them.
public partial class AccountingContext : DbContext
{
    public AccountingContext(DbContextOptions<AccountingContext> options)
        : base(options)
    {
    }
}
