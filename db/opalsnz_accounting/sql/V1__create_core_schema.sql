-- Core schema for the accounting app - income, home office expenses, business purchases, assets,
-- and trading stock. See docs/tax/*.md for the tax rules each table is designed around.

CREATE TABLE income_entries (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    income_stream VARCHAR(32) NOT NULL,
    entry_date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    invoice_reference VARCHAR(100) NULL,
    amount_excl_gst DECIMAL(12,2) NOT NULL,
    gst_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_income_entries_stream CHECK (income_stream IN ('SoftwareDevelopment', 'OpalSales'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

CREATE TABLE expense_categories (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    default_claim_percent DECIMAL(5,2) NOT NULL,
    has_gst TINYINT(1) NOT NULL DEFAULT 1,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_expense_categories_name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

CREATE TABLE home_office_expense_entries (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    expense_category_id BIGINT NOT NULL,
    entry_date DATE NOT NULL,
    gross_amount DECIMAL(12,2) NOT NULL,
    claim_percent DECIMAL(5,2) NOT NULL,
    has_gst TINYINT(1) NOT NULL,
    claimable_amount DECIMAL(12,2) NOT NULL,
    claimable_gst DECIMAL(12,2) NOT NULL DEFAULT 0,
    notes VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_home_office_expense_entries_category FOREIGN KEY (expense_category_id) REFERENCES expense_categories (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

CREATE INDEX ix_home_office_expense_entries_category ON home_office_expense_entries (expense_category_id);

CREATE TABLE business_purchases (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    purchase_date DATE NOT NULL,
    purchase_type VARCHAR(32) NOT NULL,
    description VARCHAR(255) NOT NULL,
    supplier VARCHAR(255) NULL,
    amount_excl_gst DECIMAL(12,2) NOT NULL,
    gst_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    is_capital_asset TINYINT(1) NOT NULL DEFAULT 0,
    is_trading_stock_purchase TINYINT(1) NOT NULL DEFAULT 0,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_business_purchases_type CHECK (purchase_type IN ('OpalRoughStock', 'Tool', 'Other'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

CREATE TABLE assets (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    business_purchase_id BIGINT NULL,
    description VARCHAR(255) NOT NULL,
    purchase_date DATE NOT NULL,
    cost_excl_gst DECIMAL(12,2) NOT NULL,
    depreciation_method VARCHAR(20) NOT NULL,
    depreciation_rate DECIMAL(5,2) NOT NULL,
    is_low_value_writeoff TINYINT(1) NOT NULL DEFAULT 0,
    disposal_date DATE NULL,
    disposal_amount DECIMAL(12,2) NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_assets_business_purchase FOREIGN KEY (business_purchase_id) REFERENCES business_purchases (id),
    CONSTRAINT chk_assets_depreciation_method CHECK (depreciation_method IN ('DiminishingValue', 'StraightLine'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

CREATE INDEX ix_assets_business_purchase ON assets (business_purchase_id);

CREATE TABLE asset_depreciation_years (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    asset_id BIGINT NOT NULL,
    tax_year_start DATE NOT NULL,
    tax_year_end DATE NOT NULL,
    opening_value DECIMAL(12,2) NOT NULL,
    depreciation_amount DECIMAL(12,2) NOT NULL,
    closing_value DECIMAL(12,2) NOT NULL,
    months_owned_this_year TINYINT NOT NULL DEFAULT 12,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_asset_depreciation_years_asset FOREIGN KEY (asset_id) REFERENCES assets (id),
    CONSTRAINT uq_asset_depreciation_years_asset_year UNIQUE (asset_id, tax_year_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

CREATE TABLE trading_stock_years (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tax_year_start DATE NOT NULL,
    tax_year_end DATE NOT NULL,
    opening_value DECIMAL(12,2) NOT NULL,
    opening_value_method VARCHAR(20) NOT NULL,
    closing_value DECIMAL(12,2) NULL,
    closing_value_method VARCHAR(30) NULL,
    is_finalised TINYINT(1) NOT NULL DEFAULT 0,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_trading_stock_years_tax_year UNIQUE (tax_year_start),
    CONSTRAINT chk_trading_stock_years_opening_method CHECK (opening_value_method IN ('Cost', 'MarketValue', 'PriorYearClosing')),
    CONSTRAINT chk_trading_stock_years_closing_method CHECK (closing_value_method IS NULL OR closing_value_method IN ('Cost', 'DiscountedSellingPrice', 'ReplacementPrice', 'MarketSellingValue'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

CREATE TABLE historical_stock_purchases (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    purchase_date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    notes VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
