-- Default home-office expense categories with example claim % from docs/tax/home-office-expenses.md.
-- Percentages are editable per category in the app - these are starting points, not fixed rules.

INSERT INTO expense_categories (name, default_claim_percent, has_gst, is_active) VALUES
    ('Mortgage Interest', 25.00, 0, 1),
    ('Power', 50.00, 1, 1),
    ('Internet', 50.00, 1, 1),
    ('Rates', 25.00, 0, 1),
    ('Home & Contents Insurance', 25.00, 1, 1);
