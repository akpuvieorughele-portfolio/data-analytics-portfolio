-- ============================================================
-- SUPPLY CHAIN OPERATIONS DATABASE
-- Author: Akpuvie (Perry) Orughele
-- Description: Production-grade relational schema for
--              multi-supplier, multi-warehouse supply chain ops
-- ============================================================

-- Drop tables in reverse dependency order (safe re-run)
DROP TABLE IF EXISTS shipment_items CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS purchase_orders CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS warehouses CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ============================================================
-- DIMENSION TABLES
-- ============================================================

CREATE TABLE categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT
);

CREATE TABLE suppliers (
    supplier_id     SERIAL PRIMARY KEY,
    supplier_name   VARCHAR(150) NOT NULL,
    contact_name    VARCHAR(100),
    contact_email   VARCHAR(150),
    country         VARCHAR(100),
    city            VARCHAR(100),
    rating          NUMERIC(3,2) CHECK (rating BETWEEN 0 AND 5),
    lead_time_days  INT NOT NULL DEFAULT 7,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouses (
    warehouse_id    SERIAL PRIMARY KEY,
    warehouse_name  VARCHAR(150) NOT NULL,
    location        VARCHAR(200),
    region          VARCHAR(100),
    capacity_units  INT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    customer_name   VARCHAR(150) NOT NULL,
    segment         VARCHAR(50) CHECK (segment IN ('Retail', 'Wholesale', 'Enterprise')),
    country         VARCHAR(100),
    city            VARCHAR(100),
    email           VARCHAR(150),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(200) NOT NULL,
    sku             VARCHAR(50) UNIQUE NOT NULL,
    category_id     INT REFERENCES categories(category_id),
    supplier_id     INT REFERENCES suppliers(supplier_id),
    unit_cost       NUMERIC(10,2) NOT NULL,
    unit_price      NUMERIC(10,2) NOT NULL,
    reorder_point   INT NOT NULL DEFAULT 50,
    reorder_qty     INT NOT NULL DEFAULT 100,
    weight_kg       NUMERIC(8,2),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT positive_cost CHECK (unit_cost > 0),
    CONSTRAINT positive_price CHECK (unit_price > unit_cost)
);

-- ============================================================
-- INVENTORY
-- ============================================================

CREATE TABLE inventory (
    inventory_id        SERIAL PRIMARY KEY,
    product_id          INT NOT NULL REFERENCES products(product_id),
    warehouse_id        INT NOT NULL REFERENCES warehouses(warehouse_id),
    quantity_on_hand    INT NOT NULL DEFAULT 0,
    quantity_reserved   INT NOT NULL DEFAULT 0,
    last_counted_at     TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_product_warehouse UNIQUE (product_id, warehouse_id),
    CONSTRAINT non_negative_stock CHECK (quantity_on_hand >= 0),
    CONSTRAINT non_negative_reserved CHECK (quantity_reserved >= 0)
);

-- Computed available stock view
CREATE OR REPLACE VIEW inventory_available AS
SELECT
    i.inventory_id,
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    w.warehouse_name,
    w.region,
    i.quantity_on_hand,
    i.quantity_reserved,
    (i.quantity_on_hand - i.quantity_reserved) AS quantity_available,
    p.reorder_point,
    CASE
        WHEN (i.quantity_on_hand - i.quantity_reserved) <= p.reorder_point
        THEN TRUE ELSE FALSE
    END AS reorder_needed
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN warehouses w ON i.warehouse_id = w.warehouse_id;

-- ============================================================
-- PURCHASE ORDERS (Supplier -> Warehouse)
-- ============================================================

CREATE TABLE purchase_orders (
    po_id           SERIAL PRIMARY KEY,
    supplier_id     INT NOT NULL REFERENCES suppliers(supplier_id),
    warehouse_id    INT NOT NULL REFERENCES warehouses(warehouse_id),
    status          VARCHAR(30) NOT NULL DEFAULT 'Pending'
                    CHECK (status IN ('Pending', 'Confirmed', 'Shipped', 'Received', 'Cancelled')),
    order_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    expected_date   DATE,
    received_date   DATE,
    total_value     NUMERIC(12,2),
    notes           TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    item_id         SERIAL PRIMARY KEY,
    po_id           INT NOT NULL REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    product_id      INT NOT NULL REFERENCES products(product_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_cost       NUMERIC(10,2) NOT NULL,
    line_total      NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED
);

-- ============================================================
-- SHIPMENTS
-- ============================================================

CREATE TABLE shipments (
    shipment_id         SERIAL PRIMARY KEY,
    po_id               INT REFERENCES purchase_orders(po_id),
    customer_id         INT REFERENCES customers(customer_id),
    shipment_type       VARCHAR(20) CHECK (shipment_type IN ('Inbound', 'Outbound')),
    carrier             VARCHAR(100),
    tracking_number     VARCHAR(100),
    status              VARCHAR(30) NOT NULL DEFAULT 'Pending'
                        CHECK (status IN ('Pending', 'In Transit', 'Delivered', 'Delayed', 'Lost')),
    ship_date           DATE,
    estimated_delivery  DATE,
    actual_delivery     DATE,
    origin_warehouse    INT REFERENCES warehouses(warehouse_id),
    destination         VARCHAR(200),
    shipping_cost       NUMERIC(10,2)
);

CREATE TABLE shipment_items (
    shipment_item_id    SERIAL PRIMARY KEY,
    shipment_id         INT NOT NULL REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    product_id          INT NOT NULL REFERENCES products(product_id),
    quantity_shipped    INT NOT NULL CHECK (quantity_shipped > 0)
);

-- ============================================================
-- INDEXES FOR QUERY PERFORMANCE
-- ============================================================

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse_id);
CREATE INDEX idx_po_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_po_status ON purchase_orders(status);
CREATE INDEX idx_po_order_date ON purchase_orders(order_date);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_shipments_ship_date ON shipments(ship_date);
CREATE INDEX idx_order_items_po ON order_items(po_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
