using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Opalsnz.Accounting.Db.Models;

namespace Opalsnz.Accounting.Db;

public partial class AccountingContext : DbContext
{
    public AccountingContext(DbContextOptions<AccountingContext> options)
        : base(options)
    {
    }

    public virtual DbSet<asset> assets { get; set; }

    public virtual DbSet<asset_depreciation_year> asset_depreciation_years { get; set; }

    public virtual DbSet<business_purchase> business_purchases { get; set; }

    public virtual DbSet<expense_category> expense_categories { get; set; }

    public virtual DbSet<flyway_schema_history> flyway_schema_histories { get; set; }

    public virtual DbSet<historical_stock_purchase> historical_stock_purchases { get; set; }

    public virtual DbSet<home_office_expense_entry> home_office_expense_entries { get; set; }

    public virtual DbSet<income_entry> income_entries { get; set; }

    public virtual DbSet<trading_stock_year> trading_stock_years { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .UseCollation("utf8mb4_unicode_520_ci")
            .HasCharSet("utf8mb4");

        modelBuilder.Entity<asset>(entity =>
        {
            entity.HasKey(e => e.id).HasName("PRIMARY");

            entity.HasIndex(e => e.business_purchase_id, "ix_assets_business_purchase");

            entity.Property(e => e.cost_excl_gst).HasPrecision(12, 2);
            entity.Property(e => e.created_at)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.depreciation_method).HasMaxLength(20);
            entity.Property(e => e.depreciation_rate).HasPrecision(5, 2);
            entity.Property(e => e.description).HasMaxLength(255);
            entity.Property(e => e.disposal_amount).HasPrecision(12, 2);
            entity.Property(e => e.notes).HasColumnType("text");
            entity.Property(e => e.updated_at)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");

            entity.HasOne(d => d.business_purchase).WithMany(p => p.assets)
                .HasForeignKey(d => d.business_purchase_id)
                .HasConstraintName("fk_assets_business_purchase");
        });

        modelBuilder.Entity<asset_depreciation_year>(entity =>
        {
            entity.HasKey(e => e.id).HasName("PRIMARY");

            entity.HasIndex(e => new { e.asset_id, e.tax_year_start }, "uq_asset_depreciation_years_asset_year").IsUnique();

            entity.Property(e => e.closing_value).HasPrecision(12, 2);
            entity.Property(e => e.created_at)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.depreciation_amount).HasPrecision(12, 2);
            entity.Property(e => e.months_owned_this_year).HasDefaultValueSql("'12'");
            entity.Property(e => e.opening_value).HasPrecision(12, 2);
            entity.Property(e => e.updated_at)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");

            entity.HasOne(d => d.asset).WithMany(p => p.asset_depreciation_years)
                .HasForeignKey(d => d.asset_id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_asset_depreciation_years_asset");
        });

        modelBuilder.Entity<business_purchase>(entity =>
        {
            entity.HasKey(e => e.id).HasName("PRIMARY");

            entity.Property(e => e.amount_excl_gst).HasPrecision(12, 2);
            entity.Property(e => e.created_at)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.description).HasMaxLength(255);
            entity.Property(e => e.gst_amount).HasPrecision(12, 2);
            entity.Property(e => e.notes).HasColumnType("text");
            entity.Property(e => e.purchase_type).HasMaxLength(32);
            entity.Property(e => e.supplier).HasMaxLength(255);
            entity.Property(e => e.updated_at)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
        });

        modelBuilder.Entity<expense_category>(entity =>
        {
            entity.HasKey(e => e.id).HasName("PRIMARY");

            entity.HasIndex(e => e.name, "uq_expense_categories_name").IsUnique();

            entity.Property(e => e.created_at)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.default_claim_percent).HasPrecision(5, 2);
            entity.Property(e => e.has_gst)
                .IsRequired()
                .HasDefaultValueSql("'1'");
            entity.Property(e => e.is_active)
                .IsRequired()
                .HasDefaultValueSql("'1'");
            entity.Property(e => e.name).HasMaxLength(100);
            entity.Property(e => e.updated_at)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
        });

        modelBuilder.Entity<flyway_schema_history>(entity =>
        {
            entity.HasKey(e => e.installed_rank).HasName("PRIMARY");

            entity.ToTable("flyway_schema_history");

            entity.HasIndex(e => e.success, "flyway_schema_history_s_idx");

            entity.Property(e => e.installed_rank).ValueGeneratedNever();
            entity.Property(e => e.description).HasMaxLength(200);
            entity.Property(e => e.installed_by).HasMaxLength(100);
            entity.Property(e => e.installed_on)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp");
            entity.Property(e => e.script).HasMaxLength(1000);
            entity.Property(e => e.type).HasMaxLength(20);
            entity.Property(e => e.version).HasMaxLength(50);
        });

        modelBuilder.Entity<historical_stock_purchase>(entity =>
        {
            entity.HasKey(e => e.id).HasName("PRIMARY");

            entity.Property(e => e.amount).HasPrecision(12, 2);
            entity.Property(e => e.created_at)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.description).HasMaxLength(255);
            entity.Property(e => e.notes).HasMaxLength(255);
            entity.Property(e => e.updated_at)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
        });

        modelBuilder.Entity<home_office_expense_entry>(entity =>
        {
            entity.HasKey(e => e.id).HasName("PRIMARY");

            entity.HasIndex(e => e.expense_category_id, "ix_home_office_expense_entries_category");

            entity.Property(e => e.claim_percent).HasPrecision(5, 2);
            entity.Property(e => e.claimable_amount).HasPrecision(12, 2);
            entity.Property(e => e.claimable_gst).HasPrecision(12, 2);
            entity.Property(e => e.created_at)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.gross_amount).HasPrecision(12, 2);
            entity.Property(e => e.notes).HasMaxLength(255);
            entity.Property(e => e.updated_at)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");

            entity.HasOne(d => d.expense_category).WithMany(p => p.home_office_expense_entries)
                .HasForeignKey(d => d.expense_category_id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_home_office_expense_entries_category");
        });

        modelBuilder.Entity<income_entry>(entity =>
        {
            entity.HasKey(e => e.id).HasName("PRIMARY");

            entity.Property(e => e.amount_excl_gst).HasPrecision(12, 2);
            entity.Property(e => e.created_at)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.description).HasMaxLength(255);
            entity.Property(e => e.gst_amount).HasPrecision(12, 2);
            entity.Property(e => e.income_stream).HasMaxLength(32);
            entity.Property(e => e.invoice_reference).HasMaxLength(100);
            entity.Property(e => e.notes).HasColumnType("text");
            entity.Property(e => e.total_amount).HasPrecision(12, 2);
            entity.Property(e => e.updated_at)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
        });

        modelBuilder.Entity<trading_stock_year>(entity =>
        {
            entity.HasKey(e => e.id).HasName("PRIMARY");

            entity.HasIndex(e => e.tax_year_start, "uq_trading_stock_years_tax_year").IsUnique();

            entity.Property(e => e.closing_value).HasPrecision(12, 2);
            entity.Property(e => e.closing_value_method).HasMaxLength(30);
            entity.Property(e => e.created_at)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.notes).HasColumnType("text");
            entity.Property(e => e.opening_value).HasPrecision(12, 2);
            entity.Property(e => e.opening_value_method).HasMaxLength(20);
            entity.Property(e => e.updated_at)
                .ValueGeneratedOnAddOrUpdate()
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
