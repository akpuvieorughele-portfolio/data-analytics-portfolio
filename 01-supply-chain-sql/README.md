# Supply Chain Operations Database & Analytical Query Suite

**Tool:** SQL (PostgreSQL) | **Domain:** Supply Chain | **Type:** Database Design + Analytical Reporting

---

## Business Problem

Supply chain operations generate data across disconnected systems — orders, inventory, suppliers, and shipments. Without a well-structured relational model, cross-functional reporting is unreliable and analytical queries are slow. This project simulates and solves that problem from scratch.

## Approach

- Designed a normalized relational schema covering Orders, Products, Suppliers, Inventory, and Shipments
- Populated tables with realistic synthetic data representing multi-supplier, multi-warehouse operations
- Built an analytical query suite covering: supplier performance, inventory turnover, order fulfilment rates, and shipment delay analysis
- Indexed key foreign keys and date fields to optimize query performance

## Key Findings

- Identified supplier lead time variance as the primary driver of stockout events
- Revealed that 3 of 12 product categories accounted for 68% of delayed shipments
- Exposed inventory imbalances across warehouse locations using cross-join aggregation

## Recommendation

Implement a supplier SLA scoring model updated monthly from shipment delay data, and restructure reorder triggers based on category-level lead time averages rather than fixed thresholds.

---

## Repository Contents

| File | Description |
|------|-------------|
| `schema.sql` | Full DDL — table definitions, constraints, indexes |
| `seed_data.sql` | Synthetic data population scripts |
| `analytical_queries.sql` | Decision-ready query suite |

---

## Schema Overview

```
suppliers --> purchase_orders --> order_items --> products
                                                      |
warehouses --> inventory <--------------------------------
     |
     └--> shipments --> shipment_items
```

---

[Back to Portfolio](../README.md)
