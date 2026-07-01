-- ============================================================
-- SUPPLY CHAIN ANALYTICAL QUERY SUITE
-- Author: Akpuvie (Perry) Orughele
-- Purpose: Decision-ready reporting across supplier performance,
--          inventory health, order fulfilment, and shipment delays
-- ============================================================


-- ============================================================
-- SECTION 1: SUPPLIER PERFORMANCE
-- ============================================================

-- 1.1 Supplier On-Time Delivery Rate
-- Measures % of POs received on or before expected date
SELECT
    s.supplier_name,
    s.country,
    s.lead_time_days AS contracted_lead_days,
    COUNT(po.po_id)                                                     AS total_orders,
    SUM(CASE WHEN po.received_date <= po.expected_date THEN 1 ELSE 0 END) AS on_time_deliveries,
    ROUND(
        100.0 * SUM(CASE WHEN po.received_date <= po.expected_date THEN 1 ELSE 0 END)
        / NULLIF(COUNT(po.po_id), 0), 1
    )                                                                   AS on_time_rate_pct,
    ROUND(AVG(po.received_date - po.order_date), 1)                     AS avg_actual_lead_days
FROM suppliers s
JOIN purchase_orders po ON s.supplier_id = po.supplier_id
WHERE po.status = 'Received'
GROUP BY s.supplier_id, s.supplier_name, s.country, s.lead_time_days
ORDER BY on_time_rate_pct DESC;


-- 1.2 Supplier Spend & Value Analysis
SELECT
    s.supplier_name,
    COUNT(DISTINCT po.po_id)            AS total_pos,
    SUM(po.total_value)                 AS total_spend,
    ROUND(AVG(po.total_value), 0)       AS avg_po_value,
    SUM(oi.quantity)                    AS total_units_ordered,
    COUNT(DISTINCT oi.product_id)       AS distinct_products
FROM suppliers s
JOIN purchase_orders po ON s.supplier_id = po.supplier_id
JOIN order_items oi ON po.po_id = oi.po_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_spend DESC;


-- 1.3 Supplier Lead Time Variance
-- High variance = unreliable supply chain partner
SELECT
    s.supplier_name,
    s.lead_time_days                                        AS contracted_days,
    ROUND(AVG(po.received_date - po.order_date), 1)        AS avg_actual_days,
    ROUND(STDDEV(po.received_date - po.order_date), 1)     AS lead_time_stddev,
    MIN(po.received_date - po.order_date)                  AS fastest_days,
    MAX(po.received_date - po.order_date)                  AS slowest_days
FROM suppliers s
JOIN purchase_orders po ON s.supplier_id = po.supplier_id
WHERE po.status = 'Received'
GROUP BY s.supplier_id, s.supplier_name, s.lead_time_days
HAVING COUNT(po.po_id) >= 2
ORDER BY lead_time_stddev DESC;


-- ============================================================
-- SECTION 2: INVENTORY HEALTH
-- ============================================================

-- 2.1 Stock Status Across All Warehouses
SELECT
    p.product_name,
    p.sku,
    c.category_name,
    w.warehouse_name,
    w.region,
    i.quantity_on_hand,
    i.quantity_reserved,
    (i.quantity_on_hand - i.quantity_reserved) AS available_stock,
    p.reorder_point,
    CASE
        WHEN (i.quantity_on_hand - i.quantity_reserved) = 0   THEN 'OUT OF STOCK'
        WHEN (i.quantity_on_hand - i.quantity_reserved) <= p.reorder_point THEN 'REORDER NOW'
        WHEN (i.quantity_on_hand - i.quantity_reserved) <= p.reorder_point * 1.5 THEN 'LOW STOCK'
        ELSE 'ADEQUATE'
    END AS stock_status
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN warehouses w ON i.warehouse_id = w.warehouse_id
ORDER BY
    CASE
        WHEN (i.quantity_on_hand - i.quantity_reserved) = 0 THEN 1
        WHEN (i.quantity_on_hand - i.quantity_reserved) <= p.reorder_point THEN 2
        WHEN (i.quantity_on_hand - i.quantity_reserved) <= p.reorder_point * 1.5 THEN 3
        ELSE 4
    END,
    c.category_name;


-- 2.2 Inventory Value by Category and Warehouse
SELECT
    c.category_name,
    w.warehouse_name,
    SUM(i.quantity_on_hand)                        AS total_units,
    SUM(i.quantity_on_hand * p.unit_cost)          AS inventory_cost_value,
    SUM(i.quantity_on_hand * p.unit_price)         AS inventory_retail_value,
    SUM((i.quantity_on_hand * p.unit_price)
        - (i.quantity_on_hand * p.unit_cost))      AS potential_gross_profit
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN warehouses w ON i.warehouse_id = w.warehouse_id
GROUP BY c.category_name, w.warehouse_name
ORDER BY inventory_cost_value DESC;


-- 2.3 Products Below Reorder Point (Consolidated Across All Warehouses)
SELECT
    p.product_name,
    p.sku,
    c.category_name,
    s.supplier_name,
    s.lead_time_days,
    SUM(i.quantity_on_hand - i.quantity_reserved) AS total_available_network,
    p.reorder_point,
    p.reorder_qty,
    (p.reorder_point - SUM(i.quantity_on_hand - i.quantity_reserved)) AS units_short
FROM products p
JOIN inventory i ON p.product_id = i.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
GROUP BY p.product_id, p.product_name, p.sku, c.category_name,
         s.supplier_name, s.lead_time_days, p.reorder_point, p.reorder_qty
HAVING SUM(i.quantity_on_hand - i.quantity_reserved) < p.reorder_point
ORDER BY units_short DESC;


-- ============================================================
-- SECTION 3: PURCHASE ORDER FULFILMENT
-- ============================================================

-- 3.1 PO Fulfilment Summary by Status
SELECT
    status,
    COUNT(*)                    AS order_count,
    SUM(total_value)            AS total_value,
    ROUND(AVG(total_value), 0)  AS avg_order_value,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1
    )                           AS pct_of_total
FROM purchase_orders
GROUP BY status
ORDER BY order_count DESC;


-- 3.2 Monthly PO Volume and Spend Trend
SELECT
    TO_CHAR(DATE_TRUNC('month', order_date), 'YYYY-MM') AS order_month,
    COUNT(po_id)                AS orders_placed,
    SUM(total_value)            AS total_spend,
    ROUND(AVG(total_value), 0)  AS avg_order_value,
    SUM(COUNT(po_id)) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS cumulative_orders
FROM purchase_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;


-- 3.3 Category-Level Order Volume and Spend
SELECT
    c.category_name,
    COUNT(DISTINCT po.po_id)    AS total_pos,
    SUM(oi.quantity)            AS total_units_ordered,
    SUM(oi.line_total)          AS total_line_value,
    ROUND(AVG(oi.unit_cost), 2) AS avg_unit_cost
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN purchase_orders po ON oi.po_id = po.po_id
GROUP BY c.category_name
ORDER BY total_line_value DESC;


-- ============================================================
-- SECTION 4: SHIPMENT DELAY ANALYSIS
-- ============================================================

-- 4.1 Shipment Delay Summary
SELECT
    status,
    COUNT(*)                AS shipment_count,
    ROUND(AVG(
        CASE WHEN actual_delivery IS NOT NULL
             THEN actual_delivery - estimated_delivery
             ELSE CURRENT_DATE - estimated_delivery
        END
    ), 1)                   AS avg_delay_days,
    MAX(
        CASE WHEN actual_delivery IS NOT NULL
             THEN actual_delivery - estimated_delivery
             ELSE CURRENT_DATE - estimated_delivery
        END
    )                       AS max_delay_days
FROM shipments
GROUP BY status
ORDER BY shipment_count DESC;


-- 4.2 Carrier Performance (On-Time vs Delayed)
SELECT
    carrier,
    COUNT(*)                                AS total_shipments,
    SUM(CASE WHEN status = 'Delivered'
             AND (actual_delivery - estimated_delivery) <= 0
             THEN 1 ELSE 0 END)             AS on_time,
    SUM(CASE WHEN status = 'Delayed'
             OR (actual_delivery - estimated_delivery) > 0
             THEN 1 ELSE 0 END)             AS late,
    ROUND(
        100.0 * SUM(CASE WHEN status = 'Delivered'
                         AND (actual_delivery - estimated_delivery) <= 0
                         THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 1
    )                                       AS on_time_pct,
    SUM(shipping_cost)                      AS total_shipping_spend
FROM shipments
GROUP BY carrier
ORDER BY on_time_pct DESC;


-- 4.3 Outbound Shipment Performance by Customer
SELECT
    cu.customer_name,
    cu.segment,
    COUNT(sh.shipment_id)                   AS total_shipments,
    SUM(CASE WHEN sh.status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN sh.status = 'Delayed'   THEN 1 ELSE 0 END) AS delayed,
    SUM(sh.shipping_cost)                   AS total_shipping_cost
FROM shipments sh
JOIN customers cu ON sh.customer_id = cu.customer_id
WHERE sh.shipment_type = 'Outbound'
GROUP BY cu.customer_id, cu.customer_name, cu.segment
ORDER BY total_shipments DESC;


-- ============================================================
-- SECTION 5: EXECUTIVE SUMMARY VIEW
-- ============================================================

-- 5.1 Network-wide KPI Snapshot
SELECT
    'Total Active Products'             AS metric,
    COUNT(*)::TEXT                      AS value
FROM products WHERE is_active = TRUE

UNION ALL

SELECT
    'Total Inventory Units (On Hand)',
    SUM(quantity_on_hand)::TEXT
FROM inventory

UNION ALL

SELECT
    'Products Needing Reorder',
    COUNT(DISTINCT product_id)::TEXT
FROM inventory_available
WHERE reorder_needed = TRUE

UNION ALL

SELECT
    'Open Purchase Orders',
    COUNT(*)::TEXT
FROM purchase_orders
WHERE status IN ('Pending', 'Confirmed', 'Shipped')

UNION ALL

SELECT
    'Total PO Spend (All Time)',
    TO_CHAR(SUM(total_value), 'FM999,999,999.00')
FROM purchase_orders

UNION ALL

SELECT
    'Delayed Shipments',
    COUNT(*)::TEXT
FROM shipments
WHERE status = 'Delayed'

UNION ALL

SELECT
    'Active Suppliers',
    COUNT(*)::TEXT
FROM suppliers
WHERE is_active = TRUE;
