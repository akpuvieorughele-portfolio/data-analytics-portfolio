-- ============================================================
-- SEED DATA — Supply Chain Operations Database
-- Author: Akpuvie (Perry) Orughele
-- Realistic synthetic data for analytical demonstration
-- ============================================================

-- CATEGORIES
INSERT INTO categories (category_name, description) VALUES
('Electronics',       'Consumer and industrial electronic components'),
('Raw Materials',     'Unprocessed inputs for manufacturing'),
('Packaging',         'Boxes, wrapping, and container materials'),
('Office Supplies',   'Stationery and general office consumables'),
('Industrial Parts',  'Machinery components and spare parts'),
('Chemicals',         'Industrial and laboratory chemical compounds'),
('Food & Beverage',   'Perishable and non-perishable goods');

-- SUPPLIERS
INSERT INTO suppliers (supplier_name, contact_name, contact_email, country, city, rating, lead_time_days) VALUES
('Apex Components Ltd',       'James Okafor',    'j.okafor@apexcomp.com',      'Nigeria',      'Lagos',     4.5, 5),
('SinoTrade Manufacturing',   'Wei Li',          'wei.li@sinotrade.cn',         'China',        'Shenzhen',  3.8, 21),
('Euro Parts GmbH',           'Hans Mueller',    'h.mueller@europarts.de',      'Germany',      'Frankfurt', 4.9, 14),
('QuickShip Supplies UK',     'Sarah Patel',     's.patel@quickship.co.uk',     'UK',           'London',    4.2, 7),
('AfriSource Trading',        'Emeka Nwosu',     'e.nwosu@afrisource.ng',       'Nigeria',      'Abuja',     3.5, 10),
('PrimePack Solutions',       'Aisha Bello',     'a.bello@primepack.ng',        'Nigeria',      'Port Harcourt', 4.0, 6),
('Global Chem Imports',       'Rajiv Sharma',    'r.sharma@globalchem.in',      'India',        'Mumbai',    4.3, 18),
('FastTrack Distributors',    'Linda Chen',      'l.chen@fasttrack.sg',         'Singapore',    'Singapore', 4.7, 9);

-- WAREHOUSES
INSERT INTO warehouses (warehouse_name, location, region, capacity_units) VALUES
('Lagos Central Hub',        'Apapa, Lagos',           'South West',  50000),
('Port Harcourt Depot',      'Trans Amadi, PH',        'South South', 30000),
('Abuja Distribution Centre','Wuse II, Abuja',          'North Central', 25000),
('Warri Storage Facility',   'Effurun, Warri',          'South South', 15000),
('Kano North Hub',           'Bompai Industrial, Kano', 'North West',  20000);

-- CUSTOMERS
INSERT INTO customers (customer_name, segment, country, city, email) VALUES
('Zenith Retail Group',      'Retail',      'Nigeria', 'Lagos',        'procurement@zenithretail.ng'),
('Offshore Drilling Co.',    'Enterprise',  'Nigeria', 'Port Harcourt','supply@offshoredrilling.ng'),
('MegaMart Stores',          'Wholesale',   'Nigeria', 'Abuja',        'orders@megamart.ng'),
('Delta Industrial Ltd',     'Enterprise',  'Nigeria', 'Warri',        'logistics@deltaindustrial.ng'),
('Northern Allied Traders',  'Wholesale',   'Nigeria', 'Kano',         'purchase@northernallied.ng');

-- PRODUCTS
INSERT INTO products (product_name, sku, category_id, supplier_id, unit_cost, unit_price, reorder_point, reorder_qty) VALUES
('Industrial Circuit Breaker 40A',   'SKU-ELEC-001', 1, 3, 4500.00,  6200.00,  30,  60),
('Copper Wire Spool 2.5mm x 100m',   'SKU-ELEC-002', 1, 1, 8200.00,  11500.00, 20,  40),
('Hydraulic Oil ISO 46 (200L)',       'SKU-RAW-001',  2, 7, 35000.00, 48000.00, 10,  20),
('Steel Pipe 3" Schedule 40 (6m)',    'SKU-RAW-002',  2, 5, 12000.00, 16500.00, 25,  50),
('Corrugated Cardboard Box Large',   'SKU-PKG-001',  3, 6, 450.00,   750.00,   500, 1000),
('Stretch Wrap Film 500mm x 300m',   'SKU-PKG-002',  3, 6, 2800.00,  4200.00,  50,  100),
('A4 Copy Paper (Box of 5 Reams)',   'SKU-OFF-001',  4, 4, 3200.00,  4800.00,  100, 200),
('Ballpoint Pens Box of 50',         'SKU-OFF-002',  4, 4, 1200.00,  2000.00,  200, 500),
('Industrial Safety Gloves (Pair)',  'SKU-IND-001',  5, 2, 850.00,   1400.00,  150, 300),
('Bearing SKF 6205-2RS',             'SKU-IND-002',  5, 3, 2200.00,  3500.00,  40,  80),
('Caustic Soda 25kg Bag',            'SKU-CHM-001',  6, 7, 9500.00,  13000.00, 20,  40),
('Diesel Generator Oil 15W-40 (4L)', 'SKU-CHM-002',  6, 1, 4800.00,  7200.00,  60,  120),
('Bottled Water 50cl x 24',          'SKU-FNB-001',  7, 8, 1800.00,  2800.00,  200, 400),
('Instant Noodles Carton x 40',      'SKU-FNB-002',  7, 8, 5500.00,  8200.00,  80,  160);

-- INVENTORY (product x warehouse distribution)
INSERT INTO inventory (product_id, warehouse_id, quantity_on_hand, quantity_reserved) VALUES
(1,  1, 120, 20), (1,  2, 45,  10),
(2,  1, 80,  15), (2,  3, 30,  5),
(3,  2, 22,  8),  (3,  4, 12,  4),
(4,  1, 95,  25), (4,  4, 18,  0),
(5,  1, 2500, 300),(5, 3, 800, 100),
(6,  1, 180, 40), (6,  2, 90,  20),
(7,  3, 450, 50), (7,  5, 220, 30),
(8,  3, 820, 80), (8,  5, 600, 60),
(9,  2, 310, 70), (9,  4, 95,  20),
(10, 1, 55,  15), (10, 2, 28,  5),
(11, 2, 14,  3),  (11, 4, 8,   2),
(12, 1, 200, 45), (12, 3, 110, 20),
(13, 1, 640, 120),(13, 5, 380, 60),
(14, 3, 220, 40), (14, 5, 150, 30);

-- PURCHASE ORDERS
INSERT INTO purchase_orders (supplier_id, warehouse_id, status, order_date, expected_date, received_date, total_value) VALUES
(3, 1, 'Received',   '2025-10-01', '2025-10-15', '2025-10-14', 540000.00),
(2, 2, 'Received',   '2025-10-05', '2025-10-26', '2025-11-02', 382000.00),
(1, 4, 'Received',   '2025-10-10', '2025-10-15', '2025-10-16', 128000.00),
(7, 2, 'Received',   '2025-10-15', '2025-11-02', '2025-11-01', 247000.00),
(6, 1, 'Received',   '2025-10-20', '2025-10-26', '2025-10-27', 96000.00),
(4, 3, 'Received',   '2025-11-01', '2025-11-08', '2025-11-09', 215000.00),
(5, 4, 'Received',   '2025-11-05', '2025-11-15', '2025-11-18', 88000.00),
(8, 1, 'Received',   '2025-11-10', '2025-11-19', '2025-11-20', 173000.00),
(3, 2, 'Received',   '2025-11-15', '2025-11-29', '2025-11-28', 312000.00),
(2, 5, 'Received',   '2025-11-20', '2025-12-11', '2025-12-15', 194000.00),
(1, 1, 'Shipped',    '2025-12-01', '2025-12-06', NULL,          156000.00),
(7, 3, 'Confirmed',  '2025-12-05', '2025-12-23', NULL,          289000.00),
(6, 1, 'Pending',    '2025-12-10', '2025-12-16', NULL,          72000.00),
(4, 5, 'Confirmed',  '2025-12-12', '2025-12-19', NULL,          198000.00),
(3, 4, 'Pending',    '2025-12-15', '2025-12-29', NULL,          445000.00);

-- ORDER ITEMS
INSERT INTO order_items (po_id, product_id, quantity, unit_cost) VALUES
(1, 1,  50, 4500.00), (1, 10, 30, 2200.00),
(2, 9,  200, 850.00), (2, 3,  5,  35000.00),
(3, 12, 80, 4800.00), (3, 2,  8,  8200.00),
(4, 11, 15, 9500.00), (4, 3,  3,  35000.00),
(5, 5,  500, 450.00), (5, 6,  60, 2800.00),
(6, 7,  150, 3200.00),(6, 8,  300, 1200.00),
(7, 4,  30, 12000.00),(7, 9,  80, 850.00),
(8, 13, 200, 1800.00),(8, 14, 100, 5500.00),
(9, 1,  40, 4500.00), (9, 10, 25, 2200.00),
(10,9,  150, 850.00), (10,4,  10, 12000.00),
(11,12, 60, 4800.00), (11,2,  6,  8200.00),
(12,11, 20, 9500.00), (12,3,  2,  35000.00),
(13,5,  300, 450.00), (13,6,  30, 2800.00),
(14,7,  100, 3200.00),(14,8,  200, 1200.00),
(15,1,  60, 4500.00), (15,10, 40, 2200.00);

-- SHIPMENTS
INSERT INTO shipments (po_id, customer_id, shipment_type, carrier, tracking_number, status, ship_date, estimated_delivery, actual_delivery, origin_warehouse, destination, shipping_cost) VALUES
(1, NULL, 'Inbound',  'DHL',     'DHL-2025-10001', 'Delivered', '2025-10-12', '2025-10-15', '2025-10-14', 1, 'Lagos Central Hub',          12000.00),
(2, NULL, 'Inbound',  'Maersk',  'MSK-2025-10002', 'Delivered', '2025-10-24', '2025-10-26', '2025-11-02', 2, 'Port Harcourt Depot',         28000.00),
(3, NULL, 'Inbound',  'Haulage+','HLP-2025-10003', 'Delivered', '2025-10-13', '2025-10-15', '2025-10-16', 4, 'Warri Storage Facility',       5500.00),
(NULL, 1, 'Outbound', 'DHL',     'DHL-2025-20001', 'Delivered', '2025-10-18', '2025-10-20', '2025-10-21', 1, 'Zenith Retail, Lagos',         8000.00),
(NULL, 2, 'Outbound', 'Haulage+','HLP-2025-20002', 'Delivered', '2025-10-22', '2025-10-25', '2025-10-28', 2, 'Offshore Drilling, PH',       14000.00),
(NULL, 3, 'Outbound', 'FedEx',   'FDX-2025-20003', 'Delivered', '2025-11-05', '2025-11-07', '2025-11-07', 3, 'MegaMart Stores, Abuja',       9500.00),
(NULL, 4, 'Outbound', 'Haulage+','HLP-2025-20004', 'Delivered', '2025-11-12', '2025-11-14', '2025-11-15', 4, 'Delta Industrial, Warri',      6000.00),
(NULL, 5, 'Outbound', 'GIG',     'GIG-2025-20005', 'Delayed',   '2025-11-20', '2025-11-23', NULL,          5, 'Northern Allied, Kano',        7500.00),
(NULL, 1, 'Outbound', 'DHL',     'DHL-2025-20006', 'Delivered', '2025-11-28', '2025-11-30', '2025-11-30', 1, 'Zenith Retail, Lagos',         8500.00),
(NULL, 2, 'Outbound', 'FedEx',   'FDX-2025-20007', 'In Transit','2025-12-05', '2025-12-08', NULL,          2, 'Offshore Drilling, PH',       15000.00),
(11,  NULL,'Inbound', 'Haulage+','HLP-2025-30001', 'In Transit','2025-12-03', '2025-12-06', NULL,          1, 'Lagos Central Hub',            6500.00),
(NULL, 3, 'Outbound', 'GIG',     'GIG-2025-20008', 'Pending',   NULL,          '2025-12-18', NULL,          3, 'MegaMart Stores, Abuja',      10000.00);

-- SHIPMENT ITEMS
INSERT INTO shipment_items (shipment_id, product_id, quantity_shipped) VALUES
(1, 1,  50), (1, 10, 30),
(2, 9,  200),(2, 3,  5),
(3, 12, 80), (3, 2,  8),
(4, 5,  100),(4, 7,  50),(4, 13, 80),
(5, 9,  60), (5, 4,  10),(5, 11, 5),
(6, 7,  80), (6, 8,  150),
(7, 12, 40), (7, 9,  30),
(8, 4,  15), (8, 9,  40),
(9, 5,  200),(9, 6,  60),(9, 13, 100),
(10,1,  20), (10,10, 15),
(11,12, 60), (11,2,  6);
