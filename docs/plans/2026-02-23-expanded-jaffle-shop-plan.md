# Expanded Jaffle Shop Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Scale jaffle_shop_duckdb from 9 to 99 dbt nodes with rich interdependencies for Recce demos.

**Architecture:** 5-layer dbt project (seeds → staging → intermediate → marts → metrics/reporting) with diamond dependencies, 2 incremental models, recursive CTEs, and RFM segmentation. DuckDB backend, seed-based data loading.

**Tech Stack:** dbt-core with dbt-duckdb adapter, Python for seed data generation, DuckDB SQL dialect.

---

## Directory Structure

```
models/
  staging/           # 12 staging models (views)
  intermediate/      # 25 intermediate models (views)
  marts/             # 35 mart models (tables) - includes moved customers.sql, orders.sql
  metrics/           # 15 metric/reporting models (tables)
seeds/               # 12 seed CSVs
scripts/             # seed generation script
```

---

### Task 1: Generate Seed CSV Data

**Files:**
- Create: `scripts/generate_seeds.py`
- Create: `seeds/raw_products.csv`
- Create: `seeds/raw_categories.csv`
- Create: `seeds/raw_order_items.csv`
- Create: `seeds/raw_stores.csv`
- Create: `seeds/raw_employees.csv`
- Create: `seeds/raw_promotions.csv`
- Create: `seeds/raw_order_promotions.csv`
- Create: `seeds/raw_supply_orders.csv`
- Create: `seeds/raw_reviews.csv`

**Step 1: Write the seed generation script**

```python
#!/usr/bin/env python3
"""Generate seed CSV files for expanded jaffle shop."""
import csv
import random
import os
from datetime import date, timedelta

random.seed(42)

SEEDS_DIR = os.path.join(os.path.dirname(__file__), '..', 'seeds')

# --- raw_categories.csv ---
categories = [
    (1, 'Beverages', ''),
    (2, 'Food', ''),
    (3, 'Merchandise', ''),
    (4, 'Coffee', 1),
    (5, 'Tea', 1),
    (6, 'Smoothie', 1),
    (7, 'Juice', 1),
    (8, 'Pastry', 2),
    (9, 'Sandwich', 2),
    (10, 'Breakfast', 2),
]

with open(os.path.join(SEEDS_DIR, 'raw_categories.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'name', 'parent_category_id'])
    for cid, name, parent in categories:
        w.writerow([cid, name, parent])

# --- raw_products.csv ---
product_names = {
    4: ['Espresso', 'Americano', 'Latte', 'Cappuccino', 'Mocha', 'Cold Brew', 'Macchiato', 'Flat White'],
    5: ['Green Tea', 'Earl Grey', 'Chamomile', 'Chai Latte', 'Matcha Latte', 'Oolong'],
    6: ['Berry Blast', 'Tropical Mango', 'Green Machine', 'Peanut Butter Banana'],
    7: ['Orange Juice', 'Apple Juice', 'Carrot Ginger', 'Lemonade'],
    8: ['Croissant', 'Blueberry Muffin', 'Chocolate Scone', 'Cinnamon Roll', 'Banana Bread', 'Danish'],
    9: ['Turkey Club', 'BLT', 'Grilled Cheese', 'Veggie Wrap', 'Chicken Pesto'],
    10: ['Avocado Toast', 'Eggs Benedict', 'Pancake Stack', 'Granola Bowl', 'Breakfast Burrito'],
    3: ['Coffee Mug', 'Tote Bag', 'Gift Card $25', 'Gift Card $50', 'Travel Tumbler', 'T-Shirt'],
}

products = []
pid = 1
for cat_id, names in product_names.items():
    for name in names:
        price = random.randint(300, 2500)
        cost = int(price * random.uniform(0.25, 0.55))
        days_ago = random.randint(30, 730)
        created = date(2017, 6, 1) + timedelta(days=random.randint(0, 180))
        products.append((pid, name, cat_id, price, cost, created.isoformat()))
        pid += 1

with open(os.path.join(SEEDS_DIR, 'raw_products.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'name', 'category_id', 'price', 'cost', 'created_at'])
    for p in products:
        w.writerow(p)

NUM_PRODUCTS = len(products)

# --- raw_order_items.csv ---
order_items = []
item_id = 1
for order_id in range(1, 100):
    n_items = random.choices([1, 2, 3, 4, 5], weights=[30, 35, 20, 10, 5])[0]
    used_products = random.sample(range(1, NUM_PRODUCTS + 1), min(n_items, NUM_PRODUCTS))
    for product_id in used_products:
        qty = random.choices([1, 2, 3], weights=[70, 25, 5])[0]
        # Use product price with small variance
        base_price = products[product_id - 1][3]
        unit_price = base_price + random.randint(-50, 50)
        order_items.append((item_id, order_id, product_id, qty, max(unit_price, 100)))
        item_id += 1

with open(os.path.join(SEEDS_DIR, 'raw_order_items.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'order_id', 'product_id', 'quantity', 'unit_price'])
    for oi in order_items:
        w.writerow(oi)

# --- raw_stores.csv ---
stores = [
    (1, 'Jaffle Downtown', 'Philadelphia', 'PA', '2016-09-01'),
    (2, 'Jaffle Midtown', 'Philadelphia', 'PA', '2017-01-15'),
    (3, 'Jaffle University', 'Philadelphia', 'PA', '2017-06-01'),
    (4, 'Jaffle Suburbs', 'King of Prussia', 'PA', '2017-10-01'),
    (5, 'Jaffle Shore', 'Atlantic City', 'NJ', '2018-01-10'),
]

with open(os.path.join(SEEDS_DIR, 'raw_stores.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'name', 'city', 'state', 'opened_at'])
    for s in stores:
        w.writerow(s)

# --- raw_employees.csv ---
first_names = ['Alice', 'Bob', 'Carlos', 'Diana', 'Ethan', 'Fiona', 'George',
               'Hannah', 'Ivan', 'Julia', 'Kevin', 'Laura', 'Marco', 'Nina',
               'Oscar', 'Priya', 'Quinn', 'Rosa', 'Sam', 'Tara', 'Uma',
               'Victor', 'Wendy', 'Xander', 'Yuki', 'Zara', 'Amir', 'Beth',
               'Cleo', 'Dan']
last_names = ['Smith', 'Johnson', 'Garcia', 'Chen', 'Patel', 'Kim', 'Brown',
              'Davis', 'Rodriguez', 'Wilson', 'Lee', 'Taylor', 'Thomas',
              'Moore', 'Martin', 'White', 'Harris', 'Clark', 'Lewis', 'Hall',
              'Young', 'Allen', 'King', 'Wright', 'Lopez', 'Hill', 'Scott',
              'Adams', 'Baker', 'Nelson']
roles = ['manager', 'barista', 'barista', 'barista', 'cashier', 'cook']

employees = []
for eid in range(1, 31):
    store_id = ((eid - 1) // 6) + 1
    if store_id > 5:
        store_id = random.randint(1, 5)
    role = roles[(eid - 1) % 6]
    hired = date(2017, 1, 1) + timedelta(days=random.randint(0, 365))
    employees.append((eid, store_id, first_names[eid-1], last_names[eid-1],
                       role, hired.isoformat()))

with open(os.path.join(SEEDS_DIR, 'raw_employees.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'store_id', 'first_name', 'last_name', 'role', 'hired_at'])
    for e in employees:
        w.writerow(e)

# --- raw_promotions.csv ---
promotions = [
    (1, 'New Customer 10%', 'percentage', 10, '2018-01-01', '2018-06-30'),
    (2, 'Holiday Special', 'percentage', 15, '2018-01-01', '2018-01-31'),
    (3, 'Spring Sale', 'percentage', 20, '2018-03-01', '2018-03-31'),
    (4, '$2 Off Any Drink', 'fixed', 200, '2018-01-15', '2018-02-15'),
    (5, 'Buy More Save More', 'percentage', 25, '2018-02-01', '2018-02-28'),
    (6, 'Loyalty Reward', 'fixed', 500, '2018-01-01', '2018-12-31'),
    (7, 'Weekend Brunch Deal', 'percentage', 10, '2018-01-01', '2018-12-31'),
    (8, 'Student Discount', 'percentage', 15, '2018-01-01', '2018-12-31'),
    (9, 'Happy Hour', 'percentage', 30, '2018-01-01', '2018-12-31'),
    (10, 'Free Pastry Friday', 'fixed', 400, '2018-01-01', '2018-06-30'),
    (11, 'Summer Smoothie', 'percentage', 20, '2018-03-15', '2018-04-30'),
    (12, 'Early Bird', 'fixed', 150, '2018-01-01', '2018-12-31'),
    (13, 'Referral Bonus', 'fixed', 300, '2018-02-01', '2018-12-31'),
    (14, 'Grand Opening Shore', 'percentage', 25, '2018-01-10', '2018-02-10'),
    (15, 'Birthday Treat', 'fixed', 1000, '2018-01-01', '2018-12-31'),
]

with open(os.path.join(SEEDS_DIR, 'raw_promotions.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'name', 'discount_type', 'discount_value', 'start_date', 'end_date'])
    for p in promotions:
        w.writerow(p)

# --- raw_order_promotions.csv ---
order_promos = []
promo_orders = random.sample(range(1, 100), 40)
for order_id in sorted(promo_orders):
    promo_id = random.randint(1, 15)
    order_promos.append((order_id, promo_id))

with open(os.path.join(SEEDS_DIR, 'raw_order_promotions.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['order_id', 'promotion_id'])
    for op in order_promos:
        w.writerow(op)

# --- raw_supply_orders.csv ---
supply_orders = []
for sid in range(1, 61):
    product_id = random.randint(1, NUM_PRODUCTS)
    store_id = random.randint(1, 5)
    quantity = random.randint(10, 200)
    order_date = date(2017, 10, 1) + timedelta(days=random.randint(0, 200))
    lead_days = random.randint(2, 14)
    delivered_date = order_date + timedelta(days=lead_days)
    supply_orders.append((sid, product_id, store_id, quantity,
                          order_date.isoformat(), delivered_date.isoformat()))

with open(os.path.join(SEEDS_DIR, 'raw_supply_orders.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'product_id', 'store_id', 'quantity', 'order_date', 'delivered_date'])
    for so in supply_orders:
        w.writerow(so)

# --- raw_reviews.csv ---
reviews = []
# Pick 80 random (order, product, customer) combos from order_items
order_customer_map = {}
# Read raw_orders to get customer mapping
import csv as csv_mod
with open(os.path.join(SEEDS_DIR, 'raw_orders.csv'), 'r') as f:
    reader = csv_mod.DictReader(f)
    for row in reader:
        order_customer_map[int(row['id'])] = int(row['user_id'])

# Build pool of (order_id, product_id, customer_id) from order_items
review_pool = []
for oi in order_items:
    oid = oi[1]
    prod_id = oi[2]
    cust_id = order_customer_map.get(oid, 1)
    review_pool.append((oid, prod_id, cust_id))

selected = random.sample(review_pool, min(80, len(review_pool)))
for rid, (oid, prod_id, cust_id) in enumerate(selected, 1):
    rating = random.choices([1, 2, 3, 4, 5], weights=[5, 10, 20, 35, 30])[0]
    # Review date is 1-30 days after order date
    # Orders are in 2018, approximate
    review_date = date(2018, 1, 1) + timedelta(days=random.randint(0, 120))
    reviews.append((rid, oid, prod_id, cust_id, rating, review_date.isoformat()))

with open(os.path.join(SEEDS_DIR, 'raw_reviews.csv'), 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'order_id', 'product_id', 'customer_id', 'rating', 'review_date'])
    for r in reviews:
        w.writerow(r)

print(f"Generated seeds:")
print(f"  raw_categories: {len(categories)} rows")
print(f"  raw_products: {len(products)} rows")
print(f"  raw_order_items: {len(order_items)} rows")
print(f"  raw_stores: {len(stores)} rows")
print(f"  raw_employees: {len(employees)} rows")
print(f"  raw_promotions: {len(promotions)} rows")
print(f"  raw_order_promotions: {len(order_promos)} rows")
print(f"  raw_supply_orders: {len(supply_orders)} rows")
print(f"  raw_reviews: {len(reviews)} rows")
```

**Step 2: Run the script**

Run: `python scripts/generate_seeds.py`
Expected: 9 CSV files created in seeds/ with correct row counts.

**Step 3: Verify seed files exist and have headers**

Run: `head -2 seeds/raw_products.csv seeds/raw_categories.csv seeds/raw_order_items.csv seeds/raw_stores.csv seeds/raw_employees.csv seeds/raw_promotions.csv seeds/raw_order_promotions.csv seeds/raw_supply_orders.csv seeds/raw_reviews.csv`
Expected: Each file shows header + first data row.

**Step 4: Commit**

```bash
git add scripts/generate_seeds.py seeds/raw_products.csv seeds/raw_categories.csv seeds/raw_order_items.csv seeds/raw_stores.csv seeds/raw_employees.csv seeds/raw_promotions.csv seeds/raw_order_promotions.csv seeds/raw_supply_orders.csv seeds/raw_reviews.csv
git commit -m "feat: add seed data for expanded jaffle shop (9 new CSVs)"
```

---

### Task 2: Create New Staging Models

**Files:**
- Create: `models/staging/stg_products.sql`
- Create: `models/staging/stg_categories.sql`
- Create: `models/staging/stg_order_items.sql`
- Create: `models/staging/stg_stores.sql`
- Create: `models/staging/stg_employees.sql`
- Create: `models/staging/stg_promotions.sql`
- Create: `models/staging/stg_order_promotions.sql`
- Create: `models/staging/stg_supply_orders.sql`
- Create: `models/staging/stg_reviews.sql`
- Modify: `models/staging/schema.yml`

**Step 1: Create all 9 staging models**

`models/staging/stg_products.sql`:
```sql
with source as (
    select * from {{ ref('raw_products') }}
),

renamed as (
    select
        id as product_id,
        name as product_name,
        category_id,
        price as price_cents,
        cost as cost_cents,
        cast(price as decimal) / 100 as price,
        cast(cost as decimal) / 100 as cost,
        cast(created_at as date) as created_at
    from source
)

select * from renamed
```

`models/staging/stg_categories.sql`:
```sql
with source as (
    select * from {{ ref('raw_categories') }}
),

renamed as (
    select
        id as category_id,
        name as category_name,
        case when parent_category_id = '' then null
             else cast(parent_category_id as integer)
        end as parent_category_id
    from source
)

select * from renamed
```

`models/staging/stg_order_items.sql`:
```sql
with source as (
    select * from {{ ref('raw_order_items') }}
),

renamed as (
    select
        id as order_item_id,
        order_id,
        product_id,
        quantity,
        cast(unit_price as decimal) / 100 as unit_price
    from source
)

select * from renamed
```

`models/staging/stg_stores.sql`:
```sql
with source as (
    select * from {{ ref('raw_stores') }}
),

renamed as (
    select
        id as store_id,
        name as store_name,
        city,
        state,
        cast(opened_at as date) as opened_at
    from source
)

select * from renamed
```

`models/staging/stg_employees.sql`:
```sql
with source as (
    select * from {{ ref('raw_employees') }}
),

renamed as (
    select
        id as employee_id,
        store_id,
        first_name,
        last_name,
        role,
        cast(hired_at as date) as hired_at
    from source
)

select * from renamed
```

`models/staging/stg_promotions.sql`:
```sql
with source as (
    select * from {{ ref('raw_promotions') }}
),

renamed as (
    select
        id as promotion_id,
        name as promotion_name,
        discount_type,
        cast(discount_value as decimal) as discount_value,
        cast(start_date as date) as start_date,
        cast(end_date as date) as end_date
    from source
)

select * from renamed
```

`models/staging/stg_order_promotions.sql`:
```sql
with source as (
    select * from {{ ref('raw_order_promotions') }}
),

renamed as (
    select
        order_id,
        promotion_id
    from source
)

select * from renamed
```

`models/staging/stg_supply_orders.sql`:
```sql
with source as (
    select * from {{ ref('raw_supply_orders') }}
),

renamed as (
    select
        id as supply_order_id,
        product_id,
        store_id,
        quantity,
        cast(order_date as date) as order_date,
        cast(delivered_date as date) as delivered_date
    from source
)

select * from renamed
```

`models/staging/stg_reviews.sql`:
```sql
with source as (
    select * from {{ ref('raw_reviews') }}
),

renamed as (
    select
        id as review_id,
        order_id,
        product_id,
        customer_id,
        rating,
        cast(review_date as date) as review_date
    from source
)

select * from renamed
```

**Step 2: Update staging schema.yml**

Append to `models/staging/schema.yml`:
```yaml
  - name: stg_products
    columns:
      - name: product_id
        tests:
          - unique
          - not_null

  - name: stg_categories
    columns:
      - name: category_id
        tests:
          - unique
          - not_null

  - name: stg_order_items
    columns:
      - name: order_item_id
        tests:
          - unique
          - not_null

  - name: stg_stores
    columns:
      - name: store_id
        tests:
          - unique
          - not_null

  - name: stg_employees
    columns:
      - name: employee_id
        tests:
          - unique
          - not_null

  - name: stg_promotions
    columns:
      - name: promotion_id
        tests:
          - unique
          - not_null

  - name: stg_order_promotions
    description: Junction table linking orders to promotions

  - name: stg_supply_orders
    columns:
      - name: supply_order_id
        tests:
          - unique
          - not_null

  - name: stg_reviews
    columns:
      - name: review_id
        tests:
          - unique
          - not_null
```

**Step 3: Run dbt to verify staging models compile**

Run: `dbt run --select staging`
Expected: All 12 staging models succeed.

**Step 4: Commit**

```bash
git add models/staging/
git commit -m "feat: add 9 new staging models for expanded domains"
```

---

### Task 3: Intermediate Product Domain (5 models)

**Files:**
- Create: `models/intermediate/int_category_hierarchy.sql`
- Create: `models/intermediate/int_products_with_categories.sql`
- Create: `models/intermediate/int_product_margins.sql`
- Create: `models/intermediate/int_order_items_with_products.sql`
- Create: `models/intermediate/int_order_items_enriched.sql`

**Step 1: Create all 5 models**

`models/intermediate/int_category_hierarchy.sql`:
```sql
with recursive category_tree as (
    -- Base case: root categories (no parent)
    select
        category_id,
        category_name,
        parent_category_id,
        category_name as root_category,
        category_name as full_path,
        0 as depth
    from {{ ref('stg_categories') }}
    where parent_category_id is null

    union all

    -- Recursive case: child categories
    select
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ct.root_category,
        ct.full_path || ' > ' || c.category_name as full_path,
        ct.depth + 1 as depth
    from {{ ref('stg_categories') }} c
    inner join category_tree ct on c.parent_category_id = ct.category_id
)

select * from category_tree
```

`models/intermediate/int_products_with_categories.sql`:
```sql
with products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select * from {{ ref('int_category_hierarchy') }}
),

joined as (
    select
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        c.root_category,
        c.full_path as category_path,
        c.depth as category_depth,
        p.price,
        p.cost,
        p.created_at
    from products p
    left join categories c on p.category_id = c.category_id
)

select * from joined
```

`models/intermediate/int_product_margins.sql`:
```sql
with products as (
    select * from {{ ref('stg_products') }}
),

margins as (
    select
        product_id,
        price,
        cost,
        price - cost as margin,
        case when price > 0
            then round((price - cost) / price * 100, 1)
            else 0
        end as margin_pct
    from products
)

select * from margins
```

`models/intermediate/int_order_items_with_products.sql`:
```sql
with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('int_products_with_categories') }}
),

joined as (
    select
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        p.product_name,
        p.category_name,
        p.root_category,
        p.category_path,
        oi.quantity,
        oi.unit_price,
        oi.quantity * oi.unit_price as line_total
    from order_items oi
    left join products p on oi.product_id = p.product_id
)

select * from joined
```

`models/intermediate/int_order_items_enriched.sql`:
```sql
with items as (
    select * from {{ ref('int_order_items_with_products') }}
),

margins as (
    select * from {{ ref('int_product_margins') }}
),

enriched as (
    select
        i.order_item_id,
        i.order_id,
        i.product_id,
        i.product_name,
        i.category_name,
        i.root_category,
        i.category_path,
        i.quantity,
        i.unit_price,
        i.line_total,
        m.cost,
        m.margin_pct,
        i.quantity * m.cost as line_cost,
        i.line_total - (i.quantity * m.cost) as line_margin
    from items i
    left join margins m on i.product_id = m.product_id
)

select * from enriched
```

**Step 2: Run dbt to verify**

Run: `dbt run --select intermediate.int_category_hierarchy intermediate.int_products_with_categories intermediate.int_product_margins intermediate.int_order_items_with_products intermediate.int_order_items_enriched`
Expected: All 5 models succeed (may need `dbt run --select tag:intermediate` or path selector `models/intermediate/int_category*+ models/intermediate/int_product*+ models/intermediate/int_order_items*+`).

Actually use: `dbt run --select models/intermediate/int_category_hierarchy.sql models/intermediate/int_products_with_categories.sql models/intermediate/int_product_margins.sql models/intermediate/int_order_items_with_products.sql models/intermediate/int_order_items_enriched.sql`

**Step 3: Commit**

```bash
git add models/intermediate/
git commit -m "feat: add product domain intermediate models (5 models)"
```

---

### Task 4: Intermediate Order Domain (5 models)

**Files:**
- Create: `models/intermediate/int_order_totals.sql`
- Create: `models/intermediate/int_order_payments_matched.sql`
- Create: `models/intermediate/int_orders_with_promotions.sql`
- Create: `models/intermediate/int_order_enriched.sql`
- Create: `models/intermediate/int_daily_order_summary.sql`

**Step 1: Create all 5 models**

`models/intermediate/int_order_totals.sql`:
```sql
with enriched_items as (
    select * from {{ ref('int_order_items_enriched') }}
),

order_aggs as (
    select
        order_id,
        count(*) as item_count,
        sum(quantity) as total_quantity,
        sum(line_total) as subtotal,
        sum(line_cost) as total_cost,
        sum(line_margin) as total_margin,
        count(distinct root_category) as category_count
    from enriched_items
    group by order_id
)

select * from order_aggs
```

`models/intermediate/int_order_payments_matched.sql`:
```sql
with payments as (
    select
        order_id,
        sum(amount) as total_paid,
        count(*) as payment_count,
        count(distinct payment_method) as payment_method_count
    from {{ ref('stg_payments') }}
    group by order_id
),

order_totals as (
    select * from {{ ref('int_order_totals') }}
),

matched as (
    select
        coalesce(ot.order_id, p.order_id) as order_id,
        ot.subtotal as order_subtotal,
        p.total_paid,
        p.payment_count,
        p.payment_method_count,
        case
            when p.total_paid is null then 'unpaid'
            when abs(ot.subtotal - p.total_paid) < 0.01 then 'matched'
            when p.total_paid < ot.subtotal then 'underpaid'
            else 'overpaid'
        end as payment_status
    from order_totals ot
    full outer join payments p on ot.order_id = p.order_id
)

select * from matched
```

`models/intermediate/int_orders_with_promotions.sql`:
```sql
with orders as (
    select * from {{ ref('stg_orders') }}
),

order_promotions as (
    select * from {{ ref('stg_order_promotions') }}
),

promotions as (
    select * from {{ ref('stg_promotions') }}
),

joined as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        op.promotion_id,
        p.promotion_name,
        p.discount_type,
        p.discount_value,
        case when op.promotion_id is not null then true else false end as has_promotion
    from orders o
    left join order_promotions op on o.order_id = op.order_id
    left join promotions p on op.promotion_id = p.promotion_id
)

select * from joined
```

`models/intermediate/int_order_enriched.sql`:
```sql
with orders_promos as (
    select * from {{ ref('int_orders_with_promotions') }}
),

order_totals as (
    select * from {{ ref('int_order_totals') }}
),

payment_status as (
    select * from {{ ref('int_order_payments_matched') }}
),

enriched as (
    select
        op.order_id,
        op.customer_id,
        op.order_date,
        op.status,
        ot.item_count,
        ot.total_quantity,
        ot.subtotal,
        ot.total_cost,
        ot.total_margin,
        ot.category_count,
        op.has_promotion,
        op.promotion_name,
        op.discount_type,
        op.discount_value,
        ps.total_paid,
        ps.payment_count,
        ps.payment_status,
        case
            when op.discount_type = 'percentage' then round(ot.subtotal * op.discount_value / 100, 2)
            when op.discount_type = 'fixed' then op.discount_value / 100.0
            else 0
        end as discount_amount
    from orders_promos op
    left join order_totals ot on op.order_id = ot.order_id
    left join payment_status ps on op.order_id = ps.order_id
)

select * from enriched
```

`models/intermediate/int_daily_order_summary.sql`:
```sql
{{
    config(
        materialized='incremental',
        unique_key='order_date'
    )
}}

with orders as (
    select * from {{ ref('int_order_enriched') }}
),

daily as (
    select
        order_date,
        count(*) as order_count,
        count(distinct customer_id) as unique_customers,
        sum(subtotal) as total_revenue,
        sum(total_cost) as total_cost,
        sum(total_margin) as total_margin,
        sum(total_quantity) as total_items_sold,
        sum(case when has_promotion then 1 else 0 end) as promoted_orders,
        sum(discount_amount) as total_discounts,
        avg(subtotal) as avg_order_value
    from orders

    {% if is_incremental() %}
    where order_date > (select max(order_date) from {{ this }})
    {% endif %}

    group by order_date
)

select * from daily
```

**Step 2: Run dbt to verify**

Run: `dbt run --select models/intermediate/int_order_totals.sql models/intermediate/int_order_payments_matched.sql models/intermediate/int_orders_with_promotions.sql models/intermediate/int_order_enriched.sql models/intermediate/int_daily_order_summary.sql`
Expected: All 5 models succeed.

**Step 3: Commit**

```bash
git add models/intermediate/
git commit -m "feat: add order domain intermediate models (5 models, 1 incremental)"
```

---

### Task 5: Intermediate Customer Domain (5 models)

**Files:**
- Create: `models/intermediate/int_customer_order_history.sql`
- Create: `models/intermediate/int_customer_first_last_orders.sql`
- Create: `models/intermediate/int_customer_payment_methods.sql`
- Create: `models/intermediate/int_customer_review_activity.sql`
- Create: `models/intermediate/int_customer_segments.sql`

**Step 1: Create all 5 models**

`models/intermediate/int_customer_order_history.sql`:
```sql
with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('int_order_enriched') }}
),

history as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        count(o.order_id) as total_orders,
        coalesce(sum(o.subtotal), 0) as total_spent,
        coalesce(sum(o.total_margin), 0) as total_margin_generated,
        coalesce(avg(o.subtotal), 0) as avg_order_value,
        coalesce(sum(o.total_quantity), 0) as total_items_purchased,
        count(distinct o.order_date) as distinct_order_days
    from customers c
    left join orders o on c.customer_id = o.customer_id
    group by c.customer_id, c.first_name, c.last_name
)

select * from history
```

`models/intermediate/int_customer_first_last_orders.sql`:
```sql
with orders as (
    select * from {{ ref('int_order_enriched') }}
),

first_last as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        max(order_date) - min(order_date) as customer_tenure_days,
        count(*) as lifetime_orders,
        -- Days since last order (relative to max date in dataset)
        (select max(order_date) from orders) - max(order_date) as days_since_last_order
    from orders
    group by customer_id
)

select * from first_last
```

`models/intermediate/int_customer_payment_methods.sql`:
```sql
with payments as (
    select * from {{ ref('stg_payments') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_payments as (
    select
        o.customer_id,
        p.payment_method,
        count(*) as usage_count,
        sum(p.amount) as total_amount
    from payments p
    inner join orders o on p.order_id = o.order_id
    group by o.customer_id, p.payment_method
),

pivoted as (
    select
        customer_id,
        sum(case when payment_method = 'credit_card' then total_amount else 0 end) as credit_card_total,
        sum(case when payment_method = 'bank_transfer' then total_amount else 0 end) as bank_transfer_total,
        sum(case when payment_method = 'coupon' then total_amount else 0 end) as coupon_total,
        sum(case when payment_method = 'gift_card' then total_amount else 0 end) as gift_card_total,
        -- Most used payment method
        first(payment_method order by usage_count desc) as preferred_payment_method
    from customer_payments
    group by customer_id
)

select * from pivoted
```

`models/intermediate/int_customer_review_activity.sql`:
```sql
with reviews as (
    select * from {{ ref('stg_reviews') }}
),

customer_reviews as (
    select
        customer_id,
        count(*) as review_count,
        avg(rating) as avg_rating,
        min(rating) as min_rating,
        max(rating) as max_rating,
        min(review_date) as first_review_date,
        max(review_date) as last_review_date,
        count(distinct product_id) as products_reviewed
    from reviews
    group by customer_id
)

select * from customer_reviews
```

`models/intermediate/int_customer_segments.sql`:
```sql
with order_history as (
    select * from {{ ref('int_customer_order_history') }}
),

first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

-- RFM scoring: Recency, Frequency, Monetary
rfm as (
    select
        oh.customer_id,
        oh.first_name,
        oh.last_name,
        oh.total_orders,
        oh.total_spent,
        fl.days_since_last_order,
        -- Score each dimension 1-5 using ntile
        ntile(5) over (order by fl.days_since_last_order desc) as recency_score,
        ntile(5) over (order by oh.total_orders) as frequency_score,
        ntile(5) over (order by oh.total_spent) as monetary_score
    from order_history oh
    left join first_last fl on oh.customer_id = fl.customer_id
    where oh.total_orders > 0
),

segmented as (
    select
        *,
        recency_score + frequency_score + monetary_score as rfm_total,
        case
            when recency_score >= 4 and frequency_score >= 4 and monetary_score >= 4 then 'Champion'
            when recency_score >= 4 and frequency_score >= 3 then 'Loyal'
            when recency_score >= 4 and frequency_score <= 2 then 'New Customer'
            when recency_score <= 2 and frequency_score >= 3 then 'At Risk'
            when recency_score <= 2 and frequency_score <= 2 and monetary_score >= 3 then 'Cant Lose'
            when recency_score <= 2 then 'Lost'
            else 'Potential'
        end as customer_segment
    from rfm
)

select * from segmented
```

**Step 2: Run dbt to verify**

Run: `dbt run --select models/intermediate/int_customer_order_history.sql models/intermediate/int_customer_first_last_orders.sql models/intermediate/int_customer_payment_methods.sql models/intermediate/int_customer_review_activity.sql models/intermediate/int_customer_segments.sql`
Expected: All 5 models succeed.

**Step 3: Commit**

```bash
git add models/intermediate/
git commit -m "feat: add customer domain intermediate models (5 models, RFM segmentation)"
```

---

### Task 6: Intermediate Store, Supply Chain, Review Domain (10 models)

**Files:**
- Create: `models/intermediate/int_store_employees_active.sql`
- Create: `models/intermediate/int_store_order_assignments.sql`
- Create: `models/intermediate/int_store_revenue.sql`
- Create: `models/intermediate/int_store_performance.sql`
- Create: `models/intermediate/int_supply_order_costs.sql`
- Create: `models/intermediate/int_inventory_movements.sql`
- Create: `models/intermediate/int_product_stock_levels.sql`
- Create: `models/intermediate/int_reviews_with_products.sql`
- Create: `models/intermediate/int_product_ratings.sql`
- Create: `models/intermediate/int_promotion_effectiveness.sql`

**Step 1: Create all 10 models**

`models/intermediate/int_store_employees_active.sql`:
```sql
with employees as (
    select * from {{ ref('stg_employees') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

store_staff as (
    select
        s.store_id,
        s.store_name,
        s.city,
        s.state,
        count(*) as total_employees,
        sum(case when e.role = 'manager' then 1 else 0 end) as manager_count,
        sum(case when e.role = 'barista' then 1 else 0 end) as barista_count,
        sum(case when e.role = 'cashier' then 1 else 0 end) as cashier_count,
        sum(case when e.role = 'cook' then 1 else 0 end) as cook_count,
        min(e.hired_at) as earliest_hire,
        max(e.hired_at) as latest_hire
    from stores s
    left join employees e on s.store_id = e.store_id
    group by s.store_id, s.store_name, s.city, s.state
)

select * from store_staff
```

`models/intermediate/int_store_order_assignments.sql`:
```sql
-- Assign orders to stores using deterministic hash of order_id
with orders as (
    select * from {{ ref('stg_orders') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

assigned as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        -- Deterministic store assignment based on order_id mod store count
        ((o.order_id - 1) % (select count(*) from stores)) + 1 as store_id
    from orders o
)

select * from assigned
```

`models/intermediate/int_store_revenue.sql`:
```sql
with assignments as (
    select * from {{ ref('int_store_order_assignments') }}
),

orders as (
    select * from {{ ref('int_order_enriched') }}
),

store_rev as (
    select
        a.store_id,
        count(distinct a.order_id) as order_count,
        count(distinct a.customer_id) as unique_customers,
        sum(o.subtotal) as total_revenue,
        sum(o.total_cost) as total_cost,
        sum(o.total_margin) as total_margin,
        avg(o.subtotal) as avg_order_value
    from assignments a
    inner join orders o on a.order_id = o.order_id
    group by a.store_id
)

select * from store_rev
```

`models/intermediate/int_store_performance.sql`:
```sql
with revenue as (
    select * from {{ ref('int_store_revenue') }}
),

staff as (
    select * from {{ ref('int_store_employees_active') }}
),

performance as (
    select
        s.store_id,
        s.store_name,
        s.city,
        s.state,
        s.total_employees,
        r.order_count,
        r.unique_customers,
        r.total_revenue,
        r.total_margin,
        r.avg_order_value,
        case when s.total_employees > 0
            then round(r.total_revenue / s.total_employees, 2)
            else 0
        end as revenue_per_employee,
        case when s.total_employees > 0
            then round(cast(r.order_count as decimal) / s.total_employees, 1)
            else 0
        end as orders_per_employee
    from staff s
    left join revenue r on s.store_id = r.store_id
)

select * from performance
```

`models/intermediate/int_supply_order_costs.sql`:
```sql
with supply_orders as (
    select * from {{ ref('stg_supply_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

costed as (
    select
        so.supply_order_id,
        so.product_id,
        p.product_name,
        so.store_id,
        so.quantity,
        p.cost as unit_cost,
        so.quantity * p.cost as total_cost,
        so.order_date,
        so.delivered_date,
        so.delivered_date - so.order_date as lead_time_days
    from supply_orders so
    left join products p on so.product_id = p.product_id
)

select * from costed
```

`models/intermediate/int_inventory_movements.sql`:
```sql
with supply_in as (
    select
        product_id,
        store_id,
        delivered_date as movement_date,
        quantity as quantity_in,
        0 as quantity_out,
        'supply' as movement_type
    from {{ ref('stg_supply_orders') }}
),

-- Sales out: order items through store assignments
order_items as (
    select * from {{ ref('int_order_items_with_products') }}
),

store_assignments as (
    select * from {{ ref('int_store_order_assignments') }}
),

sales_out as (
    select
        oi.product_id,
        sa.store_id,
        sa.order_date as movement_date,
        0 as quantity_in,
        oi.quantity as quantity_out,
        'sale' as movement_type
    from order_items oi
    inner join store_assignments sa on oi.order_id = sa.order_id
),

combined as (
    select * from supply_in
    union all
    select * from sales_out
)

select * from combined
```

`models/intermediate/int_product_stock_levels.sql`:
```sql
{{
    config(
        materialized='incremental',
        unique_key='product_store_key'
    )
}}

with movements as (
    select * from {{ ref('int_inventory_movements') }}
),

stock as (
    select
        product_id || '-' || store_id as product_store_key,
        product_id,
        store_id,
        sum(quantity_in) as total_received,
        sum(quantity_out) as total_sold,
        sum(quantity_in) - sum(quantity_out) as current_stock,
        max(case when movement_type = 'supply' then movement_date end) as last_restock_date,
        max(case when movement_type = 'sale' then movement_date end) as last_sale_date
    from movements

    {% if is_incremental() %}
    where movement_date > (select max(coalesce(last_restock_date, last_sale_date)) from {{ this }})
    {% endif %}

    group by product_id, store_id
)

select * from stock
```

`models/intermediate/int_reviews_with_products.sql`:
```sql
with reviews as (
    select * from {{ ref('stg_reviews') }}
),

products as (
    select * from {{ ref('int_products_with_categories') }}
),

enriched as (
    select
        r.review_id,
        r.order_id,
        r.product_id,
        p.product_name,
        p.category_name,
        p.root_category,
        r.customer_id,
        r.rating,
        r.review_date
    from reviews r
    left join products p on r.product_id = p.product_id
)

select * from enriched
```

`models/intermediate/int_product_ratings.sql`:
```sql
with reviews as (
    select * from {{ ref('int_reviews_with_products') }}
),

ratings as (
    select
        product_id,
        product_name,
        category_name,
        root_category,
        count(*) as review_count,
        round(avg(rating), 2) as avg_rating,
        sum(case when rating >= 4 then 1 else 0 end) as positive_reviews,
        sum(case when rating <= 2 then 1 else 0 end) as negative_reviews,
        min(rating) as min_rating,
        max(rating) as max_rating
    from reviews
    group by product_id, product_name, category_name, root_category
)

select * from ratings
```

`models/intermediate/int_promotion_effectiveness.sql`:
```sql
with orders_with_promos as (
    select * from {{ ref('int_orders_with_promotions') }}
),

order_totals as (
    select * from {{ ref('int_order_totals') }}
),

effectiveness as (
    select
        owp.has_promotion,
        owp.promotion_name,
        owp.discount_type,
        count(*) as order_count,
        avg(ot.subtotal) as avg_order_value,
        sum(ot.subtotal) as total_revenue,
        avg(ot.item_count) as avg_items_per_order,
        avg(ot.total_margin) as avg_margin
    from orders_with_promos owp
    left join order_totals ot on owp.order_id = ot.order_id
    group by owp.has_promotion, owp.promotion_name, owp.discount_type
)

select * from effectiveness
```

**Step 2: Run dbt to verify all intermediate models**

Run: `dbt run --select models/intermediate/`
Expected: All 25 intermediate models succeed.

**Step 3: Commit**

```bash
git add models/intermediate/
git commit -m "feat: add store, supply chain, and review intermediate models (10 models, 1 incremental)"
```

---

### Task 7: Update dbt_project.yml and Move Existing Models

**Files:**
- Modify: `dbt_project.yml`
- Move: `models/customers.sql` → `models/marts/customers.sql`
- Move: `models/orders.sql` → `models/marts/orders.sql`
- Move: `models/new_orders.sql` → `models/marts/new_orders.sql`
- Move: `models/schema.yml` → `models/marts/schema.yml`
- Move: `models/docs.md` → `models/marts/docs.md`

**Step 1: Update dbt_project.yml**

Replace the `models:` section in `dbt_project.yml`:
```yaml
name: 'jaffle_shop'

config-version: 2
version: '0.1'

profile: 'jaffle_shop'

model-paths: ["models"]
seed-paths: ["seeds"]
test-paths: ["tests"]
analysis-paths: ["analysis"]
macro-paths: ["macros"]

target-path: "target"
clean-targets:
    - "target"
    - "dbt_modules"
    - "logs"

require-dbt-version: [">=1.0.0", "<2.0.0"]

seeds:
  +docs:
    node_color: '#cd7f32'

models:
  jaffle_shop:
    +materialized: table
    staging:
      +materialized: view
      +docs:
        node_color: 'silver'
    intermediate:
      +materialized: view
      +docs:
        node_color: '#4169E1'
    marts:
      +materialized: table
      +docs:
        node_color: 'gold'
    metrics:
      +materialized: table
      +docs:
        node_color: '#9370DB'
```

**Step 2: Move existing models into marts/**

```bash
mkdir -p models/marts
mv models/customers.sql models/marts/customers.sql
mv models/orders.sql models/marts/orders.sql
mv models/new_orders.sql models/marts/new_orders.sql
mv models/schema.yml models/marts/schema.yml
mv models/docs.md models/marts/docs.md
```

**Step 3: Run dbt to verify existing models still work**

Run: `dbt run --select models/marts/customers.sql models/marts/orders.sql models/marts/new_orders.sql`
Expected: All 3 models succeed (refs resolve by name, not path).

**Step 4: Commit**

```bash
git add dbt_project.yml models/marts/ models/
git commit -m "refactor: reorganize project structure with intermediate, marts, metrics layers"
```

---

### Task 8: Customer & Order Mart Models (12 new models)

**Files:**
- Create: `models/marts/customer_lifetime_value.sql`
- Create: `models/marts/customer_segments_final.sql`
- Create: `models/marts/customer_retention.sql`
- Create: `models/marts/customer_acquisition.sql`
- Create: `models/marts/customer_360.sql`
- Create: `models/marts/customer_cohorts.sql`
- Create: `models/marts/customer_review_summary.sql`
- Create: `models/marts/order_items.sql`
- Create: `models/marts/order_returns.sql`
- Create: `models/marts/order_discounts.sql`
- Create: `models/marts/order_fulfillment.sql`
- Create: `models/marts/order_payment_status.sql`

**Step 1: Create all customer mart models**

`models/marts/customer_lifetime_value.sql`:
```sql
with customers as (
    select * from {{ ref('customers') }}
),

first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

clv as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.number_of_orders,
        c.customer_lifetime_value as total_revenue,
        fl.first_order_date,
        fl.last_order_date,
        fl.customer_tenure_days,
        fl.days_since_last_order,
        case when fl.customer_tenure_days > 0
            then round(c.customer_lifetime_value / (fl.customer_tenure_days / 30.0), 2)
            else c.customer_lifetime_value
        end as monthly_value,
        case when c.number_of_orders > 0
            then round(c.customer_lifetime_value / c.number_of_orders, 2)
            else 0
        end as avg_order_value
    from customers c
    left join first_last fl on c.customer_id = fl.customer_id
)

select * from clv
```

`models/marts/customer_segments_final.sql`:
```sql
with segments as (
    select * from {{ ref('int_customer_segments') }}
),

final as (
    select
        customer_id,
        first_name,
        last_name,
        customer_segment,
        recency_score,
        frequency_score,
        monetary_score,
        rfm_total,
        total_orders,
        total_spent,
        days_since_last_order
    from segments
)

select * from final
```

`models/marts/customer_retention.sql`:
```sql
with first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

orders as (
    select * from {{ ref('int_order_enriched') }}
),

-- Monthly cohorts
cohort_orders as (
    select
        fl.customer_id,
        date_trunc('month', fl.first_order_date) as cohort_month,
        date_trunc('month', o.order_date) as order_month,
        (date_part('year', o.order_date) - date_part('year', fl.first_order_date)) * 12
            + date_part('month', o.order_date) - date_part('month', fl.first_order_date) as months_since_first
    from first_last fl
    inner join orders o on fl.customer_id = o.customer_id
),

retention as (
    select
        cohort_month,
        months_since_first,
        count(distinct customer_id) as customers
    from cohort_orders
    group by cohort_month, months_since_first
)

select * from retention
```

`models/marts/customer_acquisition.sql`:
```sql
with first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

orders as (
    select * from {{ ref('int_order_enriched') }}
),

first_order_details as (
    select
        fl.customer_id,
        fl.first_order_date,
        o.has_promotion as acquired_via_promotion,
        o.promotion_name as acquisition_promotion,
        o.subtotal as first_order_value,
        o.item_count as first_order_items,
        date_trunc('month', fl.first_order_date) as acquisition_month
    from first_last fl
    inner join orders o on fl.customer_id = o.customer_id
        and fl.first_order_date = o.order_date
)

select * from first_order_details
```

`models/marts/customer_360.sql`:
```sql
with customers as (
    select * from {{ ref('customers') }}
),

clv as (
    select * from {{ ref('customer_lifetime_value') }}
),

retention as (
    select
        customer_id,
        max(months_since_first) as months_active
    from {{ ref('customer_retention') }}
    group by customer_id
),

reviews as (
    select * from {{ ref('int_customer_review_activity') }}
),

segments as (
    select * from {{ ref('customer_segments_final') }}
),

unified as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.first_order,
        c.most_recent_order,
        c.number_of_orders,
        c.customer_lifetime_value,
        clv.monthly_value,
        clv.avg_order_value,
        clv.customer_tenure_days,
        clv.days_since_last_order,
        s.customer_segment,
        s.rfm_total,
        coalesce(r.review_count, 0) as review_count,
        r.avg_rating as avg_review_rating,
        coalesce(ret.months_active, 0) as months_active
    from customers c
    left join clv on c.customer_id = clv.customer_id
    left join segments s on c.customer_id = s.customer_id
    left join reviews r on c.customer_id = r.customer_id
    left join retention ret on c.customer_id = ret.customer_id
)

select * from unified
```

`models/marts/customer_cohorts.sql`:
```sql
with first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

cohorts as (
    select
        date_trunc('month', first_order_date) as cohort_month,
        count(*) as cohort_size,
        avg(lifetime_orders) as avg_lifetime_orders,
        avg(customer_tenure_days) as avg_tenure_days
    from first_last
    group by date_trunc('month', first_order_date)
)

select * from cohorts
```

`models/marts/customer_review_summary.sql`:
```sql
with reviews as (
    select * from {{ ref('int_customer_review_activity') }}
),

ratings as (
    select * from {{ ref('int_product_ratings') }}
),

summary as (
    select
        r.customer_id,
        r.review_count,
        r.avg_rating as customer_avg_rating,
        r.products_reviewed,
        r.first_review_date,
        r.last_review_date,
        -- Compare to overall product averages
        avg(pr.avg_rating) as avg_product_rating_of_reviewed,
        case when r.avg_rating > avg(pr.avg_rating) then 'above_average'
             when r.avg_rating < avg(pr.avg_rating) then 'below_average'
             else 'average'
        end as rating_tendency
    from reviews r
    left join {{ ref('stg_reviews') }} sr on r.customer_id = sr.customer_id
    left join ratings pr on sr.product_id = pr.product_id
    group by r.customer_id, r.review_count, r.avg_rating, r.products_reviewed,
             r.first_review_date, r.last_review_date
)

select * from summary
```

**Step 2: Create all order mart models**

`models/marts/order_items.sql`:
```sql
select * from {{ ref('int_order_items_enriched') }}
```

`models/marts/order_returns.sql`:
```sql
with orders as (
    select * from {{ ref('orders') }}
),

returns as (
    select
        *,
        case
            when status in ('returned', 'Sreturned') then 'completed_return'
            when status in ('return_pending', 'Sreturn_pending') then 'pending_return'
        end as return_status
    from orders
    where status in ('returned', 'return_pending', 'Sreturned', 'Sreturn_pending')
)

select * from returns
```

`models/marts/order_discounts.sql`:
```sql
with orders as (
    select * from {{ ref('int_order_enriched') }}
),

items as (
    select * from {{ ref('int_order_items_enriched') }}
),

discounts as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.subtotal,
        o.has_promotion,
        o.promotion_name,
        o.discount_type,
        o.discount_value,
        o.discount_amount,
        case when o.subtotal > 0
            then round(o.discount_amount / o.subtotal * 100, 1)
            else 0
        end as discount_pct_of_order,
        o.subtotal - o.discount_amount as net_revenue
    from orders o
    where o.has_promotion = true
)

select * from discounts
```

`models/marts/order_fulfillment.sql`:
```sql
with orders as (
    select * from {{ ref('orders') }}
),

assignments as (
    select * from {{ ref('int_store_order_assignments') }}
),

staff as (
    select * from {{ ref('int_store_employees_active') }}
),

fulfillment as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        o.amount,
        a.store_id,
        s.store_name,
        s.city,
        s.state,
        s.total_employees as store_employee_count
    from orders o
    left join assignments a on o.order_id = a.order_id
    left join staff s on a.store_id = s.store_id
)

select * from fulfillment
```

`models/marts/order_payment_status.sql`:
```sql
with matched as (
    select * from {{ ref('int_order_payments_matched') }}
),

final as (
    select
        order_id,
        order_subtotal,
        total_paid,
        payment_count,
        payment_method_count,
        payment_status,
        coalesce(total_paid, 0) - coalesce(order_subtotal, 0) as payment_difference
    from matched
)

select * from final
```

**Step 2: Run dbt to verify**

Run: `dbt run --select models/marts/`
Expected: All mart models succeed.

**Step 3: Commit**

```bash
git add models/marts/
git commit -m "feat: add customer and order mart models (12 new models)"
```

---

### Task 9: Product, Store, Finance, Supply Mart Models (20 models)

**Files:**
- Create: `models/marts/products.sql`
- Create: `models/marts/product_performance.sql`
- Create: `models/marts/product_categories.sql`
- Create: `models/marts/product_inventory.sql`
- Create: `models/marts/product_reviews.sql`
- Create: `models/marts/product_profitability.sql`
- Create: `models/marts/stores.sql`
- Create: `models/marts/store_performance.sql`
- Create: `models/marts/store_staffing.sql`
- Create: `models/marts/store_inventory.sql`
- Create: `models/marts/store_rankings.sql`
- Create: `models/marts/payments_fact.sql`
- Create: `models/marts/revenue_summary.sql`
- Create: `models/marts/promotion_roi.sql`
- Create: `models/marts/cost_analysis.sql`
- Create: `models/marts/gross_margin.sql`
- Create: `models/marts/supply_orders_fact.sql`
- Create: `models/marts/supplier_lead_times.sql`
- Create: `models/marts/reorder_recommendations.sql`
- Create: `models/marts/inventory_health.sql`

**Step 1: Create product mart models**

`models/marts/products.sql`:
```sql
with products as (
    select * from {{ ref('int_products_with_categories') }}
),

margins as (
    select * from {{ ref('int_product_margins') }}
),

final as (
    select
        p.product_id,
        p.product_name,
        p.category_id,
        p.category_name,
        p.root_category,
        p.category_path,
        p.price,
        p.cost,
        m.margin,
        m.margin_pct,
        p.created_at
    from products p
    left join margins m on p.product_id = m.product_id
)

select * from final
```

`models/marts/product_performance.sql`:
```sql
with products as (
    select * from {{ ref('products') }}
),

items as (
    select
        product_id,
        count(*) as times_ordered,
        sum(quantity) as total_quantity_sold,
        sum(line_total) as total_revenue,
        sum(line_margin) as total_margin
    from {{ ref('order_items') }}
    group by product_id
),

ratings as (
    select * from {{ ref('int_product_ratings') }}
),

performance as (
    select
        p.product_id,
        p.product_name,
        p.category_name,
        p.root_category,
        p.price,
        p.cost,
        p.margin_pct,
        coalesce(i.times_ordered, 0) as times_ordered,
        coalesce(i.total_quantity_sold, 0) as total_quantity_sold,
        coalesce(i.total_revenue, 0) as total_revenue,
        coalesce(i.total_margin, 0) as total_margin,
        r.review_count,
        r.avg_rating,
        r.positive_reviews,
        r.negative_reviews
    from products p
    left join items i on p.product_id = i.product_id
    left join ratings r on p.product_id = r.product_id
)

select * from performance
```

`models/marts/product_categories.sql`:
```sql
with hierarchy as (
    select * from {{ ref('int_category_hierarchy') }}
),

product_counts as (
    select
        category_id,
        count(*) as product_count
    from {{ ref('stg_products') }}
    group by category_id
),

final as (
    select
        h.category_id,
        h.category_name,
        h.parent_category_id,
        h.root_category,
        h.full_path,
        h.depth,
        coalesce(pc.product_count, 0) as product_count
    from hierarchy h
    left join product_counts pc on h.category_id = pc.category_id
)

select * from final
```

`models/marts/product_inventory.sql`:
```sql
with stock as (
    select * from {{ ref('int_product_stock_levels') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

final as (
    select
        s.product_store_key,
        s.product_id,
        p.product_name,
        s.store_id,
        st.store_name,
        s.total_received,
        s.total_sold,
        s.current_stock,
        s.last_restock_date,
        s.last_sale_date,
        case
            when s.current_stock <= 0 then 'out_of_stock'
            when s.current_stock < 10 then 'low_stock'
            when s.current_stock < 50 then 'adequate'
            else 'well_stocked'
        end as stock_status
    from stock s
    left join products p on s.product_id = p.product_id
    left join stores st on s.store_id = st.store_id
)

select * from final
```

`models/marts/product_reviews.sql`:
```sql
with ratings as (
    select * from {{ ref('int_product_ratings') }}
),

final as (
    select
        product_id,
        product_name,
        category_name,
        root_category,
        review_count,
        avg_rating,
        positive_reviews,
        negative_reviews,
        case
            when avg_rating >= 4.5 then 'excellent'
            when avg_rating >= 3.5 then 'good'
            when avg_rating >= 2.5 then 'average'
            when avg_rating >= 1.5 then 'poor'
            else 'terrible'
        end as rating_tier,
        case when review_count > 0
            then round(cast(positive_reviews as decimal) / review_count * 100, 1)
            else 0
        end as positive_pct
    from ratings
)

select * from final
```

`models/marts/product_profitability.sql`:
```sql
with performance as (
    select * from {{ ref('product_performance') }}
),

supply_costs as (
    select
        product_id,
        sum(total_cost) as total_supply_cost,
        sum(quantity) as total_supplied
    from {{ ref('int_supply_order_costs') }}
    group by product_id
),

profitability as (
    select
        p.product_id,
        p.product_name,
        p.category_name,
        p.total_revenue,
        p.total_margin as gross_margin,
        coalesce(sc.total_supply_cost, 0) as total_supply_cost,
        p.total_revenue - coalesce(sc.total_supply_cost, 0) as net_margin,
        case when p.total_revenue > 0
            then round(p.total_margin / p.total_revenue * 100, 1)
            else 0
        end as gross_margin_pct,
        p.total_quantity_sold,
        coalesce(sc.total_supplied, 0) as total_supplied,
        p.avg_rating
    from performance p
    left join supply_costs sc on p.product_id = sc.product_id
)

select * from profitability
```

**Step 2: Create store mart models**

`models/marts/stores.sql`:
```sql
with staff as (
    select * from {{ ref('int_store_employees_active') }}
),

final as (
    select
        store_id,
        store_name,
        city,
        state,
        total_employees,
        manager_count,
        barista_count,
        cashier_count,
        cook_count,
        earliest_hire,
        latest_hire
    from staff
)

select * from final
```

`models/marts/store_performance.sql`:
```sql
select * from {{ ref('int_store_performance') }}
```

`models/marts/store_staffing.sql`:
```sql
with employees as (
    select * from {{ ref('stg_employees') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

staffing as (
    select
        e.employee_id,
        e.first_name,
        e.last_name,
        e.role,
        e.hired_at,
        e.store_id,
        s.store_name,
        s.city,
        s.state
    from employees e
    left join stores s on e.store_id = s.store_id
)

select * from staffing
```

`models/marts/store_inventory.sql`:
```sql
with inventory as (
    select * from {{ ref('product_inventory') }}
),

store_level as (
    select
        store_id,
        store_name,
        count(distinct product_id) as unique_products,
        sum(current_stock) as total_stock_units,
        sum(case when stock_status = 'out_of_stock' then 1 else 0 end) as out_of_stock_products,
        sum(case when stock_status = 'low_stock' then 1 else 0 end) as low_stock_products,
        sum(case when stock_status = 'adequate' then 1 else 0 end) as adequate_stock_products,
        sum(case when stock_status = 'well_stocked' then 1 else 0 end) as well_stocked_products
    from inventory
    group by store_id, store_name
)

select * from store_level
```

`models/marts/store_rankings.sql`:
```sql
with performance as (
    select * from {{ ref('store_performance') }}
),

ranked as (
    select
        store_id,
        store_name,
        city,
        state,
        total_revenue,
        total_margin,
        order_count,
        unique_customers,
        revenue_per_employee,
        rank() over (order by total_revenue desc) as revenue_rank,
        rank() over (order by total_margin desc) as margin_rank,
        rank() over (order by order_count desc) as order_count_rank,
        rank() over (order by revenue_per_employee desc) as efficiency_rank,
        rank() over (order by unique_customers desc) as customer_reach_rank
    from performance
)

select * from ranked
```

**Step 3: Create finance mart models**

`models/marts/payments_fact.sql`:
```sql
with payments as (
    select * from {{ ref('stg_payments') }}
),

orders as (
    select * from {{ ref('orders') }}
),

final as (
    select
        p.payment_id,
        p.order_id,
        o.customer_id,
        o.order_date,
        p.payment_method,
        p.amount,
        o.status as order_status
    from payments p
    left join orders o on p.order_id = o.order_id
)

select * from final
```

`models/marts/revenue_summary.sql`:
```sql
with orders as (
    select * from {{ ref('int_order_enriched') }}
),

assignments as (
    select * from {{ ref('int_store_order_assignments') }}
),

summary as (
    select
        o.order_date,
        date_trunc('week', o.order_date) as order_week,
        date_trunc('month', o.order_date) as order_month,
        a.store_id,
        count(*) as order_count,
        sum(o.subtotal) as revenue,
        sum(o.total_cost) as cost,
        sum(o.total_margin) as margin,
        sum(o.discount_amount) as discounts,
        sum(o.subtotal) - sum(o.discount_amount) as net_revenue
    from orders o
    left join assignments a on o.order_id = a.order_id
    group by o.order_date, date_trunc('week', o.order_date),
             date_trunc('month', o.order_date), a.store_id
)

select * from summary
```

`models/marts/promotion_roi.sql`:
```sql
with effectiveness as (
    select * from {{ ref('int_promotion_effectiveness') }}
),

discounts as (
    select
        promotion_name,
        count(*) as usage_count,
        sum(discount_amount) as total_discount_given,
        sum(net_revenue) as total_net_revenue
    from {{ ref('order_discounts') }}
    group by promotion_name
),

roi as (
    select
        e.promotion_name,
        e.discount_type,
        e.order_count,
        e.avg_order_value,
        e.total_revenue,
        e.avg_margin,
        coalesce(d.total_discount_given, 0) as total_discount_given,
        coalesce(d.total_net_revenue, 0) as net_revenue_after_discount,
        case when coalesce(d.total_discount_given, 0) > 0
            then round(coalesce(d.total_net_revenue, 0) / d.total_discount_given, 2)
            else 0
        end as revenue_per_discount_dollar
    from effectiveness e
    left join discounts d on e.promotion_name = d.promotion_name
    where e.has_promotion = true
)

select * from roi
```

`models/marts/cost_analysis.sql`:
```sql
with supply_costs as (
    select
        product_id,
        product_name,
        count(*) as supply_order_count,
        sum(quantity) as total_units_ordered,
        sum(total_cost) as total_supply_spend,
        avg(unit_cost) as avg_unit_cost,
        avg(lead_time_days) as avg_lead_time
    from {{ ref('int_supply_order_costs') }}
    group by product_id, product_name
),

product_prof as (
    select * from {{ ref('product_profitability') }}
),

analysis as (
    select
        pp.product_id,
        pp.product_name,
        pp.category_name,
        pp.total_revenue,
        pp.gross_margin,
        sc.total_supply_spend,
        sc.avg_unit_cost,
        sc.avg_lead_time,
        sc.supply_order_count,
        pp.total_quantity_sold,
        case when pp.total_quantity_sold > 0
            then round(sc.total_supply_spend / pp.total_quantity_sold, 2)
            else 0
        end as supply_cost_per_unit_sold
    from product_prof pp
    left join supply_costs sc on pp.product_id = sc.product_id
)

select * from analysis
```

`models/marts/gross_margin.sql`:
```sql
with revenue as (
    select * from {{ ref('revenue_summary') }}
),

margin_summary as (
    select
        order_month,
        store_id,
        sum(revenue) as total_revenue,
        sum(cost) as total_cost,
        sum(margin) as total_margin,
        sum(discounts) as total_discounts,
        sum(net_revenue) as total_net_revenue,
        case when sum(revenue) > 0
            then round(sum(margin) / sum(revenue) * 100, 1)
            else 0
        end as gross_margin_pct,
        sum(order_count) as total_orders
    from revenue
    group by order_month, store_id
)

select * from margin_summary
```

**Step 4: Create supply chain mart models**

`models/marts/supply_orders_fact.sql`:
```sql
select * from {{ ref('int_supply_order_costs') }}
```

`models/marts/supplier_lead_times.sql`:
```sql
with supply as (
    select * from {{ ref('int_supply_order_costs') }}
),

lead_times as (
    select
        product_id,
        product_name,
        store_id,
        count(*) as order_count,
        avg(lead_time_days) as avg_lead_time,
        min(lead_time_days) as min_lead_time,
        max(lead_time_days) as max_lead_time,
        sum(quantity) as total_quantity,
        sum(total_cost) as total_spend
    from supply
    group by product_id, product_name, store_id
)

select * from lead_times
```

`models/marts/reorder_recommendations.sql`:
```sql
with stock as (
    select * from {{ ref('product_inventory') }}
),

performance as (
    select * from {{ ref('product_performance') }}
),

recommendations as (
    select
        s.product_id,
        s.product_name,
        s.store_id,
        s.store_name,
        s.current_stock,
        s.stock_status,
        s.last_restock_date,
        p.total_quantity_sold,
        p.times_ordered,
        case
            when s.stock_status = 'out_of_stock' then 'urgent'
            when s.stock_status = 'low_stock' then 'soon'
            when s.stock_status = 'adequate' and p.times_ordered > 5 then 'monitor'
            else 'ok'
        end as reorder_priority,
        -- Suggest reorder quantity: enough for ~2x recent sales
        greatest(50 - s.current_stock, 0) as suggested_reorder_qty
    from stock s
    left join performance p on s.product_id = p.product_id
)

select * from recommendations
```

`models/marts/inventory_health.sql`:
```sql
with inventory as (
    select * from {{ ref('product_inventory') }}
),

movements as (
    select
        product_id,
        store_id,
        sum(quantity_in) as total_inbound,
        sum(quantity_out) as total_outbound,
        count(case when movement_type = 'supply' then 1 end) as restock_events,
        count(case when movement_type = 'sale' then 1 end) as sale_events
    from {{ ref('int_inventory_movements') }}
    group by product_id, store_id
),

health as (
    select
        i.product_store_key,
        i.product_id,
        i.product_name,
        i.store_id,
        i.store_name,
        i.current_stock,
        i.stock_status,
        m.total_inbound,
        m.total_outbound,
        m.restock_events,
        m.sale_events,
        case
            when m.total_outbound > m.total_inbound then 'deficit'
            when i.current_stock > m.total_outbound * 2 then 'overstocked'
            else 'balanced'
        end as inventory_balance,
        case when m.sale_events > 0
            then round(cast(m.total_outbound as decimal) / m.sale_events, 1)
            else 0
        end as avg_units_per_sale
    from inventory i
    left join movements m on i.product_id = m.product_id and i.store_id = m.store_id
)

select * from health
```

**Step 5: Run dbt to verify**

Run: `dbt run --select models/marts/`
Expected: All mart models succeed.

**Step 6: Commit**

```bash
git add models/marts/
git commit -m "feat: add product, store, finance, and supply chain mart models (20 models)"
```

---

### Task 10: Metrics and Reporting Models (15 models)

**Files:**
- Create: `models/metrics/metric_daily_revenue.sql`
- Create: `models/metrics/metric_daily_orders.sql`
- Create: `models/metrics/metric_weekly_sales.sql`
- Create: `models/metrics/metric_monthly_sales.sql`
- Create: `models/metrics/metric_customer_acquisition_monthly.sql`
- Create: `models/metrics/metric_customer_retention_monthly.sql`
- Create: `models/metrics/metric_product_sales_daily.sql`
- Create: `models/metrics/metric_store_daily.sql`
- Create: `models/metrics/metric_promotion_daily.sql`
- Create: `models/metrics/metric_inventory_daily.sql`
- Create: `models/metrics/rpt_executive_dashboard.sql`
- Create: `models/metrics/rpt_sales_dashboard.sql`
- Create: `models/metrics/rpt_customer_dashboard.sql`
- Create: `models/metrics/rpt_product_dashboard.sql`
- Create: `models/metrics/rpt_store_dashboard.sql`

**Step 1: Create metric models**

`models/metrics/metric_daily_revenue.sql`:
```sql
with daily as (
    select * from {{ ref('int_daily_order_summary') }}
),

final as (
    select
        order_date,
        order_count,
        total_revenue,
        total_cost,
        total_margin,
        total_discounts,
        total_revenue - total_discounts as net_revenue,
        avg_order_value,
        unique_customers,
        total_items_sold
    from daily
)

select * from final
```

`models/metrics/metric_daily_orders.sql`:
```sql
with orders as (
    select * from {{ ref('int_order_enriched') }}
),

daily as (
    select
        order_date,
        count(*) as total_orders,
        sum(case when status in ('completed', 'Scompleted') then 1 else 0 end) as completed_orders,
        sum(case when status in ('returned', 'Sreturned', 'return_pending', 'Sreturn_pending') then 1 else 0 end) as returned_orders,
        sum(case when status in ('shipped', 'Sshipped') then 1 else 0 end) as shipped_orders,
        sum(case when status in ('placed', 'Splaced') then 1 else 0 end) as placed_orders,
        sum(case when has_promotion then 1 else 0 end) as promoted_orders,
        avg(item_count) as avg_items_per_order
    from orders
    group by order_date
)

select * from daily
```

`models/metrics/metric_weekly_sales.sql`:
```sql
with daily as (
    select * from {{ ref('metric_daily_revenue') }}
),

weekly as (
    select
        date_trunc('week', order_date) as week_start,
        sum(order_count) as total_orders,
        sum(total_revenue) as total_revenue,
        sum(net_revenue) as net_revenue,
        sum(total_margin) as total_margin,
        sum(total_discounts) as total_discounts,
        sum(unique_customers) as total_customer_visits,
        avg(avg_order_value) as avg_daily_order_value,
        sum(total_items_sold) as total_items_sold
    from daily
    group by date_trunc('week', order_date)
)

select * from weekly
```

`models/metrics/metric_monthly_sales.sql`:
```sql
with daily as (
    select * from {{ ref('metric_daily_revenue') }}
),

monthly as (
    select
        date_trunc('month', order_date) as month_start,
        sum(order_count) as total_orders,
        sum(total_revenue) as total_revenue,
        sum(net_revenue) as net_revenue,
        sum(total_margin) as total_margin,
        sum(total_discounts) as total_discounts,
        avg(avg_order_value) as avg_daily_order_value,
        sum(total_items_sold) as total_items_sold,
        count(distinct order_date) as active_days
    from daily
    group by date_trunc('month', order_date)
)

select * from monthly
```

`models/metrics/metric_customer_acquisition_monthly.sql`:
```sql
with cohorts as (
    select * from {{ ref('customer_cohorts') }}
),

final as (
    select
        cohort_month,
        cohort_size as new_customers,
        avg_lifetime_orders,
        avg_tenure_days,
        sum(cohort_size) over (order by cohort_month) as cumulative_customers
    from cohorts
)

select * from final
```

`models/metrics/metric_customer_retention_monthly.sql`:
```sql
with retention as (
    select * from {{ ref('customer_retention') }}
),

cohort_sizes as (
    select
        cohort_month,
        customers as cohort_size
    from retention
    where months_since_first = 0
),

rates as (
    select
        r.cohort_month,
        r.months_since_first,
        r.customers as retained_customers,
        cs.cohort_size,
        round(cast(r.customers as decimal) / cs.cohort_size * 100, 1) as retention_rate
    from retention r
    inner join cohort_sizes cs on r.cohort_month = cs.cohort_month
)

select * from rates
```

`models/metrics/metric_product_sales_daily.sql`:
```sql
with items as (
    select * from {{ ref('order_items') }}
),

orders as (
    select order_id, order_date from {{ ref('int_order_enriched') }}
),

daily_product as (
    select
        o.order_date,
        i.product_id,
        i.product_name,
        i.category_name,
        sum(i.quantity) as units_sold,
        sum(i.line_total) as revenue,
        sum(i.line_margin) as margin,
        count(distinct o.order_id) as order_count
    from items i
    inner join orders o on i.order_id = o.order_id
    group by o.order_date, i.product_id, i.product_name, i.category_name
)

select * from daily_product
```

`models/metrics/metric_store_daily.sql`:
```sql
with revenue as (
    select * from {{ ref('revenue_summary') }}
),

stores as (
    select * from {{ ref('stores') }}
),

daily as (
    select
        r.order_date,
        r.store_id,
        s.store_name,
        s.city,
        r.order_count,
        r.revenue,
        r.cost,
        r.margin,
        r.discounts,
        r.net_revenue
    from revenue r
    left join stores s on r.store_id = s.store_id
)

select * from daily
```

`models/metrics/metric_promotion_daily.sql`:
```sql
with discounts as (
    select * from {{ ref('order_discounts') }}
),

daily as (
    select
        order_date,
        promotion_name,
        discount_type,
        count(*) as usage_count,
        sum(discount_amount) as total_discount,
        sum(subtotal) as total_order_value,
        sum(net_revenue) as total_net_revenue,
        avg(discount_pct_of_order) as avg_discount_pct
    from discounts
    group by order_date, promotion_name, discount_type
)

select * from daily
```

`models/metrics/metric_inventory_daily.sql`:
```sql
with inventory as (
    select * from {{ ref('product_inventory') }}
),

snapshot as (
    select
        current_date as snapshot_date,
        count(distinct product_id) as total_products_tracked,
        count(distinct store_id) as total_stores,
        sum(current_stock) as total_stock_units,
        sum(case when stock_status = 'out_of_stock' then 1 else 0 end) as out_of_stock_count,
        sum(case when stock_status = 'low_stock' then 1 else 0 end) as low_stock_count,
        sum(case when stock_status = 'adequate' then 1 else 0 end) as adequate_count,
        sum(case when stock_status = 'well_stocked' then 1 else 0 end) as well_stocked_count,
        round(avg(current_stock), 1) as avg_stock_per_product_store
    from inventory
)

select * from snapshot
```

**Step 2: Create reporting dashboard models**

`models/metrics/rpt_executive_dashboard.sql`:
```sql
with monthly_sales as (
    select * from {{ ref('metric_monthly_sales') }}
),

segments as (
    select
        customer_segment,
        count(*) as customer_count,
        sum(total_spent) as segment_revenue
    from {{ ref('customer_segments_final') }}
    group by customer_segment
),

margin as (
    select
        sum(total_revenue) as total_revenue,
        sum(total_margin) as total_margin,
        sum(total_net_revenue) as total_net_revenue,
        round(sum(total_margin) / nullif(sum(total_revenue), 0) * 100, 1) as overall_margin_pct
    from {{ ref('gross_margin') }}
),

final as (
    select
        ms.month_start,
        ms.total_orders,
        ms.total_revenue,
        ms.net_revenue,
        ms.total_margin,
        m.overall_margin_pct,
        ms.total_items_sold,
        ms.active_days
    from monthly_sales ms
    cross join margin m
)

select * from final
```

`models/metrics/rpt_sales_dashboard.sql`:
```sql
with weekly as (
    select * from {{ ref('metric_weekly_sales') }}
),

daily_orders as (
    select * from {{ ref('metric_daily_orders') }}
),

final as (
    select
        w.week_start,
        w.total_orders,
        w.total_revenue,
        w.net_revenue,
        w.total_margin,
        w.total_discounts,
        w.total_items_sold,
        w.avg_daily_order_value,
        -- Week-over-week growth
        lag(w.total_revenue) over (order by w.week_start) as prev_week_revenue,
        case when lag(w.total_revenue) over (order by w.week_start) > 0
            then round((w.total_revenue - lag(w.total_revenue) over (order by w.week_start))
                / lag(w.total_revenue) over (order by w.week_start) * 100, 1)
            else null
        end as revenue_wow_growth_pct
    from weekly w
)

select * from final
```

`models/metrics/rpt_customer_dashboard.sql`:
```sql
with customer_360 as (
    select * from {{ ref('customer_360') }}
),

cohorts as (
    select * from {{ ref('customer_cohorts') }}
),

retention as (
    select * from {{ ref('metric_customer_retention_monthly') }}
),

summary as (
    select
        count(*) as total_customers,
        count(case when number_of_orders > 0 then 1 end) as active_customers,
        avg(customer_lifetime_value) as avg_clv,
        avg(number_of_orders) as avg_orders_per_customer,
        count(case when customer_segment = 'Champion' then 1 end) as champion_customers,
        count(case when customer_segment = 'At Risk' then 1 end) as at_risk_customers,
        count(case when customer_segment = 'Lost' then 1 end) as lost_customers,
        avg(review_count) as avg_reviews_per_customer
    from customer_360
)

select * from summary
```

`models/metrics/rpt_product_dashboard.sql`:
```sql
with performance as (
    select * from {{ ref('product_performance') }}
),

reviews as (
    select * from {{ ref('product_reviews') }}
),

health as (
    select
        inventory_balance,
        count(*) as product_count
    from {{ ref('inventory_health') }}
    group by inventory_balance
),

summary as (
    select
        count(*) as total_products,
        sum(total_revenue) as total_product_revenue,
        avg(avg_rating) as overall_avg_rating,
        sum(total_quantity_sold) as total_units_sold,
        count(case when times_ordered = 0 then 1 end) as never_ordered_products,
        max(total_revenue) as top_product_revenue,
        -- Top product by revenue
        first(product_name order by total_revenue desc) as top_product_name
    from performance
)

select * from summary
```

`models/metrics/rpt_store_dashboard.sql`:
```sql
with rankings as (
    select * from {{ ref('store_rankings') }}
),

inventory as (
    select * from {{ ref('store_inventory') }}
),

daily as (
    select
        store_id,
        count(distinct order_date) as active_days,
        avg(revenue) as avg_daily_revenue
    from {{ ref('metric_store_daily') }}
    group by store_id
),

dashboard as (
    select
        r.store_id,
        r.store_name,
        r.city,
        r.state,
        r.total_revenue,
        r.total_margin,
        r.order_count,
        r.unique_customers,
        r.revenue_per_employee,
        r.revenue_rank,
        r.efficiency_rank,
        i.total_stock_units,
        i.out_of_stock_products,
        i.low_stock_products,
        d.active_days,
        d.avg_daily_revenue
    from rankings r
    left join inventory i on r.store_id = i.store_id
    left join daily d on r.store_id = d.store_id
)

select * from dashboard
```

**Step 3: Run dbt to verify**

Run: `dbt run --select models/metrics/`
Expected: All 15 metrics/reporting models succeed.

**Step 4: Commit**

```bash
git add models/metrics/
git commit -m "feat: add metrics and reporting dashboard models (15 models)"
```

---

### Task 11: Add Schema Files for New Layers

**Files:**
- Create: `models/intermediate/schema.yml`
- Create: `models/metrics/schema.yml`
- Modify: `models/marts/schema.yml` (add new models)

**Step 1: Create intermediate schema.yml**

`models/intermediate/schema.yml`:
```yaml
version: 2

models:
  - name: int_category_hierarchy
    description: Recursive flattening of category parent-child tree
    columns:
      - name: category_id
        tests:
          - not_null

  - name: int_products_with_categories
    description: Products joined to their full category hierarchy
    columns:
      - name: product_id
        tests:
          - unique
          - not_null

  - name: int_product_margins
    description: Product-level margin calculations
    columns:
      - name: product_id
        tests:
          - unique
          - not_null

  - name: int_order_items_with_products
    description: Order line items enriched with product and category info
    columns:
      - name: order_item_id
        tests:
          - unique
          - not_null

  - name: int_order_items_enriched
    description: Order line items with margin data
    columns:
      - name: order_item_id
        tests:
          - unique
          - not_null

  - name: int_order_totals
    description: Order-level aggregations from line items
    columns:
      - name: order_id
        tests:
          - unique
          - not_null

  - name: int_order_payments_matched
    description: Payment-to-order matching with status flags

  - name: int_orders_with_promotions
    description: Orders joined to their promotion details

  - name: int_order_enriched
    description: Fully enriched orders with totals, promotions, and payment status

  - name: int_daily_order_summary
    description: Incremental daily order aggregation
    columns:
      - name: order_date
        tests:
          - unique
          - not_null

  - name: int_customer_order_history
    description: Per-customer order statistics
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null

  - name: int_customer_first_last_orders
    description: First and last order dates per customer

  - name: int_customer_payment_methods
    description: Customer payment method preferences

  - name: int_customer_review_activity
    description: Customer review statistics

  - name: int_customer_segments
    description: RFM-based customer segmentation

  - name: int_store_employees_active
    description: Store-level employee counts by role

  - name: int_store_order_assignments
    description: Deterministic order-to-store mapping

  - name: int_store_revenue
    description: Store-level revenue aggregation

  - name: int_store_performance
    description: Store performance with efficiency metrics

  - name: int_supply_order_costs
    description: Supply orders with cost calculations

  - name: int_inventory_movements
    description: Combined supply and sales inventory movements

  - name: int_product_stock_levels
    description: Incremental product stock level calculation

  - name: int_reviews_with_products
    description: Reviews enriched with product info

  - name: int_product_ratings
    description: Product-level rating aggregation

  - name: int_promotion_effectiveness
    description: Promotion vs non-promotion order comparison
```

**Step 2: Create metrics schema.yml**

`models/metrics/schema.yml`:
```yaml
version: 2

models:
  - name: metric_daily_revenue
    description: Daily revenue metrics
  - name: metric_daily_orders
    description: Daily order count by status
  - name: metric_weekly_sales
    description: Weekly sales rollup
  - name: metric_monthly_sales
    description: Monthly sales rollup
  - name: metric_customer_acquisition_monthly
    description: Monthly new customer counts
  - name: metric_customer_retention_monthly
    description: Monthly cohort retention rates
  - name: metric_product_sales_daily
    description: Product-level daily sales
  - name: metric_store_daily
    description: Store-level daily metrics
  - name: metric_promotion_daily
    description: Promotion daily effectiveness
  - name: metric_inventory_daily
    description: Inventory snapshot metrics
  - name: rpt_executive_dashboard
    description: Executive-level KPI summary
  - name: rpt_sales_dashboard
    description: Sales-focused dashboard with WoW growth
  - name: rpt_customer_dashboard
    description: Customer-focused dashboard summary
  - name: rpt_product_dashboard
    description: Product-focused dashboard summary
  - name: rpt_store_dashboard
    description: Store-focused dashboard with rankings
```

**Step 3: Run dbt test to verify schema**

Run: `dbt test --select models/intermediate/ models/metrics/`
Expected: All tests pass.

**Step 4: Commit**

```bash
git add models/intermediate/schema.yml models/metrics/schema.yml
git commit -m "feat: add schema definitions for intermediate and metrics layers"
```

---

### Task 12: Full Verification

**Step 1: Run dbt seed**

Run: `dbt seed`
Expected: All 12 seeds load successfully.

**Step 2: Run dbt run (full project)**

Run: `dbt run`
Expected: All ~87 models succeed. Count should be ~87 models.

**Step 3: Run dbt test**

Run: `dbt test`
Expected: All tests pass.

**Step 4: Verify node count**

Run: `dbt ls --resource-type model | wc -l`
Expected: ~87 (12 staging + 25 intermediate + 35 marts + 15 metrics).

Run: `dbt ls --resource-type seed | wc -l`
Expected: 12.

Run: `dbt ls | wc -l`
Expected: ~99+ (models + seeds + tests).

**Step 5: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: resolve any issues from full verification run"
```
