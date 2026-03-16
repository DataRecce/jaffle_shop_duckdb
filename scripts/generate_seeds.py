#!/usr/bin/env python3
"""
Generate seed CSV files for the jaffle_shop_duckdb dbt project.

This script creates 9 new seed CSV files in the seeds/ directory.
It does NOT modify the existing 3 seed files (raw_customers, raw_orders, raw_payments).

Usage:
    python scripts/generate_seeds.py
"""

import csv
import os
import random
from datetime import date, timedelta

# Reproducibility
random.seed(42)

# Paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
SEEDS_DIR = os.path.join(PROJECT_DIR, "seeds")


def read_existing_orders():
    """Read raw_orders.csv to build order_id -> customer_id mapping."""
    orders = {}
    path = os.path.join(SEEDS_DIR, "raw_orders.csv")
    with open(path, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            orders[int(row["id"])] = int(row["user_id"])
    return orders


def write_csv(filename, headers, rows):
    """Write a CSV file to the seeds directory."""
    path = os.path.join(SEEDS_DIR, filename)
    with open(path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(rows)
    print(f"  {filename}: {len(rows)} rows")
    return path


def random_date(start, end):
    """Return a random date between start and end (inclusive)."""
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))


# ---------------------------------------------------------------------------
# 1. raw_categories.csv (~10 rows)
# ---------------------------------------------------------------------------
def generate_categories():
    rows = [
        # Root categories (no parent)
        (1, "Beverages", ""),
        (2, "Food", ""),
        (3, "Merchandise", ""),
        # Child categories
        (4, "Coffee", 1),
        (5, "Tea", 1),
        (6, "Smoothie", 1),
        (7, "Juice", 1),
        (8, "Pastry", 2),
        (9, "Sandwich", 2),
        (10, "Breakfast", 2),
    ]
    write_csv("raw_categories.csv", ["id", "name", "parent_category_id"], rows)
    return rows


# ---------------------------------------------------------------------------
# 2. raw_products.csv (~50 rows)
# ---------------------------------------------------------------------------
def generate_products():
    product_names = {
        4: [  # Coffee
            "Espresso", "Americano", "Latte", "Cappuccino", "Mocha",
            "Cold Brew", "Macchiato", "Flat White",
        ],
        5: [  # Tea
            "Earl Grey", "Green Tea", "Chai Latte", "Chamomile",
            "Matcha Latte", "Oolong Tea", "Hibiscus Tea",
        ],
        6: [  # Smoothie
            "Berry Blast Smoothie", "Tropical Smoothie", "Green Power Smoothie",
            "Mango Smoothie", "Banana Peanut Butter Smoothie",
        ],
        7: [  # Juice
            "Orange Juice", "Apple Juice", "Carrot Ginger Juice",
            "Lemonade", "Beet Juice", "Watermelon Agua Fresca",
        ],
        8: [  # Pastry
            "Croissant", "Blueberry Muffin", "Chocolate Chip Cookie",
            "Cinnamon Roll", "Banana Bread", "Scone",
        ],
        9: [  # Sandwich
            "Turkey Club", "BLT", "Grilled Cheese",
            "Veggie Wrap", "Chicken Pesto Panini", "Ham and Swiss",
        ],
        10: [  # Breakfast
            "Avocado Toast", "Breakfast Burrito", "Oatmeal Bowl",
            "Yogurt Parfait", "Egg Sandwich", "Pancake Stack",
        ],
        3: [  # Merchandise (root category)
            "Coffee Mug", "Tumbler", "Tote Bag", "T-Shirt",
            "Hoodie", "Sticker Pack",
        ],
    }

    rows = []
    product_id = 1
    for category_id, names in product_names.items():
        for name in names:
            price = random.randint(300, 2500)
            cost_pct = random.uniform(0.25, 0.55)
            cost = int(price * cost_pct)
            created_at = random_date(date(2017, 1, 1), date(2017, 12, 31))
            rows.append((product_id, name, category_id, price, cost, created_at.isoformat()))
            product_id += 1

    write_csv(
        "raw_products.csv",
        ["id", "name", "category_id", "price", "cost", "created_at"],
        rows,
    )
    return rows


# ---------------------------------------------------------------------------
# 3. raw_order_items.csv (~250 rows)
# ---------------------------------------------------------------------------
def generate_order_items(products):
    """Generate order line items. Orders 1-99, products 1-N."""
    num_products = len(products)
    rows = []
    item_id = 1

    for order_id in range(1, 100):
        num_items = random.randint(1, 5)
        # Pick distinct products for this order
        chosen_products = random.sample(range(1, num_products + 1), min(num_items, num_products))
        for pid in chosen_products:
            quantity = random.randint(1, 3)
            # Look up the product price from the products list (0-indexed, id is 1-indexed)
            unit_price = products[pid - 1][3]  # price column
            rows.append((item_id, order_id, pid, quantity, unit_price))
            item_id += 1

    write_csv(
        "raw_order_items.csv",
        ["id", "order_id", "product_id", "quantity", "unit_price"],
        rows,
    )
    return rows


# ---------------------------------------------------------------------------
# 4. raw_stores.csv (5 rows)
# ---------------------------------------------------------------------------
def generate_stores():
    stores = [
        (1, "Jaffle Shop Downtown", "Philadelphia", "PA", "2016-09-01"),
        (2, "Jaffle Shop Midtown", "New York", "NY", "2017-01-15"),
        (3, "Jaffle Shop Riverside", "Austin", "TX", "2017-04-10"),
        (4, "Jaffle Shop Lakeside", "Chicago", "IL", "2017-07-22"),
        (5, "Jaffle Shop Sunset", "San Francisco", "CA", "2017-11-05"),
    ]
    write_csv(
        "raw_stores.csv",
        ["id", "name", "city", "state", "opened_at"],
        stores,
    )
    return stores


# ---------------------------------------------------------------------------
# 5. raw_employees.csv (30 rows)
# ---------------------------------------------------------------------------
def generate_employees():
    first_names = [
        "Alice", "Bob", "Carlos", "Diana", "Ethan", "Fatima",
        "George", "Hannah", "Ivan", "Julia", "Kevin", "Luna",
        "Marcus", "Nadia", "Oscar", "Priya", "Quinn", "Rosa",
        "Samuel", "Tina", "Uma", "Victor", "Wendy", "Xavier",
        "Yara", "Zane", "Amelia", "Brian", "Clara", "Derek",
    ]
    last_names = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia",
        "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez",
        "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore",
        "Jackson", "Martin", "Lee", "Perez", "Thompson", "White",
        "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson",
    ]

    roles = ["manager", "barista", "cashier", "cook"]
    # Role distribution per store: 1 manager, 2 baristas, 1 cashier, 2 cooks
    role_template = ["manager", "barista", "barista", "cashier", "cook", "cook"]

    rows = []
    random.shuffle(first_names)
    random.shuffle(last_names)

    emp_id = 1
    for store_id in range(1, 6):
        for i, role in enumerate(role_template):
            idx = (store_id - 1) * 6 + i
            hired_at = random_date(date(2017, 1, 1), date(2018, 1, 31))
            rows.append((
                emp_id,
                store_id,
                first_names[idx],
                last_names[idx],
                role,
                hired_at.isoformat(),
            ))
            emp_id += 1

    write_csv(
        "raw_employees.csv",
        ["id", "store_id", "first_name", "last_name", "role", "hired_at"],
        rows,
    )
    return rows


# ---------------------------------------------------------------------------
# 6. raw_promotions.csv (15 rows)
# ---------------------------------------------------------------------------
def generate_promotions():
    promo_defs = [
        ("New Year Special", "percentage", 10),
        ("Valentine's Day", "percentage", 15),
        ("Spring Fling", "fixed", 200),
        ("March Madness", "percentage", 20),
        ("Tax Day Relief", "fixed", 150),
        ("Mother's Day", "percentage", 10),
        ("Summer Kickoff", "fixed", 300),
        ("Fourth of July", "percentage", 25),
        ("Back to School", "fixed", 100),
        ("Labor Day Sale", "percentage", 15),
        ("Fall Harvest", "fixed", 250),
        ("Halloween Treat", "percentage", 10),
        ("Thanksgiving", "fixed", 200),
        ("Holiday Season", "percentage", 20),
        ("Year End Blowout", "fixed", 350),
    ]

    rows = []
    # Spread promotions across 2018 (same year as orders)
    start = date(2018, 1, 1)
    for i, (name, dtype, value) in enumerate(promo_defs):
        promo_start = start + timedelta(days=i * 24)
        promo_end = promo_start + timedelta(days=random.randint(5, 14))
        rows.append((
            i + 1,
            name,
            dtype,
            value,
            promo_start.isoformat(),
            promo_end.isoformat(),
        ))

    write_csv(
        "raw_promotions.csv",
        ["id", "name", "discount_type", "discount_value", "start_date", "end_date"],
        rows,
    )
    return rows


# ---------------------------------------------------------------------------
# 7. raw_order_promotions.csv (~40 rows)
# ---------------------------------------------------------------------------
def generate_order_promotions(promotions):
    """Assign promotions to ~40% of orders."""
    rows = []
    num_promos = len(promotions)

    for order_id in range(1, 100):
        if random.random() < 0.50:
            promo_id = random.randint(1, num_promos)
            rows.append((order_id, promo_id))

    write_csv(
        "raw_order_promotions.csv",
        ["order_id", "promotion_id"],
        rows,
    )
    return rows


# ---------------------------------------------------------------------------
# 8. raw_supply_orders.csv (60 rows)
# ---------------------------------------------------------------------------
def generate_supply_orders(products):
    num_products = len(products)
    rows = []

    for supply_id in range(1, 61):
        product_id = random.randint(1, num_products)
        store_id = random.randint(1, 5)
        quantity = random.randint(10, 200)
        order_date = random_date(date(2017, 6, 1), date(2018, 4, 1))
        lead_days = random.randint(2, 14)
        delivered_date = order_date + timedelta(days=lead_days)
        rows.append((
            supply_id,
            product_id,
            store_id,
            quantity,
            order_date.isoformat(),
            delivered_date.isoformat(),
        ))

    write_csv(
        "raw_supply_orders.csv",
        ["id", "product_id", "store_id", "quantity", "order_date", "delivered_date"],
        rows,
    )
    return rows


# ---------------------------------------------------------------------------
# 9. raw_reviews.csv (80 rows)
# ---------------------------------------------------------------------------
def generate_reviews(order_items, order_to_customer):
    """
    Generate reviews that reference valid (order_id, product_id) combos
    and the correct customer for that order.
    """
    # Build list of (order_id, product_id) combos from order_items
    order_product_combos = [(row[1], row[2]) for row in order_items]  # (order_id, product_id)

    # Sample 80 combos (with replacement if needed, then deduplicate)
    # We want exactly 80 reviews, each referencing a valid combo
    chosen = random.sample(order_product_combos, min(80, len(order_product_combos)))

    # If we somehow have fewer than 80 unique combos, allow repeats
    while len(chosen) < 80:
        chosen.append(random.choice(order_product_combos))

    # Rating distribution weighted toward 4-5
    rating_weights = [1, 2, 5, 15, 20]  # weights for ratings 1-5

    rows = []
    for review_id, (order_id, product_id) in enumerate(chosen, start=1):
        customer_id = order_to_customer[order_id]
        rating = random.choices([1, 2, 3, 4, 5], weights=rating_weights, k=1)[0]
        # Review date is 1-30 days after the order (orders are in 2018)
        # Use a review date in the same general period
        review_date = random_date(date(2018, 1, 15), date(2018, 5, 15))
        rows.append((
            review_id,
            order_id,
            product_id,
            customer_id,
            rating,
            review_date.isoformat(),
        ))

    write_csv(
        "raw_reviews.csv",
        ["id", "order_id", "product_id", "customer_id", "rating", "review_date"],
        rows,
    )
    return rows


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    print("Generating seed CSV files...")
    print(f"  Output directory: {SEEDS_DIR}")
    print()

    # Read existing data
    order_to_customer = read_existing_orders()
    print(f"  Read {len(order_to_customer)} existing orders from raw_orders.csv")
    print()

    # Generate all seeds
    categories = generate_categories()
    products = generate_products()
    order_items = generate_order_items(products)
    stores = generate_stores()
    employees = generate_employees()
    promotions = generate_promotions()
    order_promotions = generate_order_promotions(promotions)
    supply_orders = generate_supply_orders(products)
    reviews = generate_reviews(order_items, order_to_customer)

    print()
    print("Done! All seed files generated successfully.")


if __name__ == "__main__":
    main()
