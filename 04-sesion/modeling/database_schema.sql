-- =====================================================
-- E-commerce Cart System - Database Schema
-- =====================================================
-- Version: 1.0
-- Description: Complete database schema for the e-commerce cart system
-- Author: Architecture Team
-- Date: 2024
-- =====================================================

-- Create database
CREATE DATABASE ecommerce_cart;
USE ecommerce_cart;

-- =====================================================
-- ENUMS
-- =====================================================

-- Order status enumeration
CREATE TYPE order_status AS ENUM (
    'pending',
    'confirmed', 
    'processing',
    'shipped',
    'delivered',
    'cancelled'
);

-- Payment status enumeration
CREATE TYPE payment_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded'
);

-- Payment method enumeration
CREATE TYPE payment_method AS ENUM (
    'credit_card',
    'paypal',
    'bank_transfer',
    'cash'
);

-- Invoice status enumeration
CREATE TYPE invoice_status AS ENUM (
    'pending',
    'paid',
    'overdue',
    'cancelled'
);

-- Currency enumeration
CREATE TYPE currency AS ENUM (
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD'
);

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Person table (base entity for users)
CREATE TABLE Person (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address_street VARCHAR(255),
    address_city VARCHAR(100),
    address_state VARCHAR(100),
    address_zip_code VARCHAR(20),
    address_country VARCHAR(100) DEFAULT 'US',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User table (authentication and authorization)
CREATE TABLE User (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP,
    person_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (person_id) REFERENCES Person(id) ON DELETE CASCADE,
    
    CONSTRAINT uk_user_person UNIQUE (person_id)
);

-- Category table
CREATE TABLE Category (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    parent_category_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_category_id) REFERENCES Category(id) ON DELETE SET NULL
);

-- Product table
CREATE TABLE Product (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    currency currency DEFAULT 'USD',
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    image_url VARCHAR(500),
    category_id BIGINT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sku VARCHAR(100) UNIQUE,
    weight DECIMAL(8,2),
    dimensions_length DECIMAL(8,2),
    dimensions_width DECIMAL(8,2),
    dimensions_height DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES Category(id),
    
    CONSTRAINT chk_product_price CHECK (price >= 0),
    CONSTRAINT chk_product_stock CHECK (stock_quantity >= 0),
    CONSTRAINT chk_product_weight CHECK (weight >= 0)
);

-- Role table
CREATE TABLE Role (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSONB NOT NULL DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User-Role junction table
CREATE TABLE UserRole (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES Role(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES User(id),
    
    CONSTRAINT uk_user_role UNIQUE (user_id, role_id)
);

-- Shopping Cart table
CREATE TABLE ShoppingCart (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES User(id) ON DELETE CASCADE,
    
    CONSTRAINT uk_customer_cart UNIQUE (customer_id)
);

-- Cart Item table
CREATE TABLE CartItem (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (cart_id) REFERENCES ShoppingCart(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE CASCADE,
    
    CONSTRAINT uk_cart_product UNIQUE (cart_id, product_id),
    CONSTRAINT chk_cart_item_quantity CHECK (quantity > 0)
);

-- Order table
CREATE TABLE Order (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    currency currency DEFAULT 'USD',
    status order_status DEFAULT 'pending',
    shipping_address_street VARCHAR(255),
    shipping_address_city VARCHAR(100),
    shipping_address_state VARCHAR(100),
    shipping_address_zip_code VARCHAR(20),
    shipping_address_country VARCHAR(100),
    billing_address_street VARCHAR(255),
    billing_address_city VARCHAR(100),
    billing_address_state VARCHAR(100),
    billing_address_zip_code VARCHAR(20),
    billing_address_country VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES User(id),
    
    CONSTRAINT chk_order_total CHECK (total_amount >= 0)
);

-- Order Item table
CREATE TABLE OrderItem (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES Order(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(id),
    
    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price CHECK (unit_price >= 0),
    CONSTRAINT chk_order_item_subtotal CHECK (subtotal >= 0)
);

-- Invoice table
CREATE TABLE Invoice (
    id BIGSERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    order_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency currency DEFAULT 'USD',
    status invoice_status DEFAULT 'pending',
    due_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES Order(id),
    
    CONSTRAINT chk_invoice_amount CHECK (amount >= 0)
);

-- Payment table
CREATE TABLE Payment (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency currency DEFAULT 'USD',
    method payment_method NOT NULL,
    status payment_status DEFAULT 'pending',
    transaction_id VARCHAR(100),
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (invoice_id) REFERENCES Invoice(id),
    
    CONSTRAINT chk_payment_amount CHECK (amount >= 0)
);

-- =====================================================
-- AUDIT TABLES
-- =====================================================

-- Audit log table
CREATE TABLE AuditLog (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    changed_by BIGINT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (changed_by) REFERENCES User(id)
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Performance indexes
CREATE INDEX idx_person_email ON Person(email);
CREATE INDEX idx_person_created_at ON Person(created_at);

CREATE INDEX idx_user_username ON User(username);
CREATE INDEX idx_user_person_id ON User(person_id);
CREATE INDEX idx_user_is_active ON User(is_active);
CREATE INDEX idx_user_last_login ON User(last_login_at);

CREATE INDEX idx_category_name ON Category(name);
CREATE INDEX idx_category_is_active ON Category(is_active);
CREATE INDEX idx_category_parent ON Category(parent_category_id);

CREATE INDEX idx_product_category_id ON Product(category_id);
CREATE INDEX idx_product_name ON Product(name);
CREATE INDEX idx_product_price ON Product(price);
CREATE INDEX idx_product_stock_quantity ON Product(stock_quantity);
CREATE INDEX idx_product_is_active ON Product(is_active);
CREATE INDEX idx_product_sku ON Product(sku);
CREATE INDEX idx_product_created_at ON Product(created_at);

-- Full-text search index for products
CREATE INDEX idx_product_search ON Product USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));

CREATE INDEX idx_role_name ON Role(name);
CREATE INDEX idx_role_is_active ON Role(is_active);

CREATE INDEX idx_user_role_user_id ON UserRole(user_id);
CREATE INDEX idx_user_role_role_id ON UserRole(role_id);
CREATE INDEX idx_user_role_is_active ON UserRole(is_active);

CREATE INDEX idx_cart_customer_id ON ShoppingCart(customer_id);
CREATE INDEX idx_cart_created_at ON ShoppingCart(created_at);

CREATE INDEX idx_cart_item_cart_id ON CartItem(cart_id);
CREATE INDEX idx_cart_item_product_id ON CartItem(product_id);

CREATE INDEX idx_order_order_number ON Order(order_number);
CREATE INDEX idx_order_customer_id ON Order(customer_id);
CREATE INDEX idx_order_status ON Order(status);
CREATE INDEX idx_order_created_at ON Order(created_at);
CREATE INDEX idx_order_customer_status ON Order(customer_id, status);

CREATE INDEX idx_order_item_order_id ON OrderItem(order_id);
CREATE INDEX idx_order_item_product_id ON OrderItem(product_id);

CREATE INDEX idx_invoice_invoice_number ON Invoice(invoice_number);
CREATE INDEX idx_invoice_order_id ON Invoice(order_id);
CREATE INDEX idx_invoice_status ON Invoice(status);
CREATE INDEX idx_invoice_due_date ON Invoice(due_date);

CREATE INDEX idx_payment_invoice_id ON Payment(invoice_id);
CREATE INDEX idx_payment_transaction_id ON Payment(transaction_id);
CREATE INDEX idx_payment_status ON Payment(status);
CREATE INDEX idx_payment_method ON Payment(method);

CREATE INDEX idx_audit_log_table_record ON AuditLog(table_name, record_id);
CREATE INDEX idx_audit_log_changed_at ON AuditLog(changed_at);
CREATE INDEX idx_audit_log_changed_by ON AuditLog(changed_by);

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all tables
CREATE TRIGGER update_person_updated_at BEFORE UPDATE ON Person FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_updated_at BEFORE UPDATE ON User FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_category_updated_at BEFORE UPDATE ON Category FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_product_updated_at BEFORE UPDATE ON Product FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_role_updated_at BEFORE UPDATE ON Role FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_role_updated_at BEFORE UPDATE ON UserRole FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cart_updated_at BEFORE UPDATE ON ShoppingCart FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cart_item_updated_at BEFORE UPDATE ON CartItem FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_order_updated_at BEFORE UPDATE ON Order FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoice_updated_at BEFORE UPDATE ON Invoice FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_updated_at BEFORE UPDATE ON Payment FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SAMPLE DATA
-- =====================================================

-- Insert sample categories
INSERT INTO Category (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Home & Garden', 'Home improvement and garden products'),
('Books', 'Books and publications'),
('Sports', 'Sports equipment and accessories');

-- Insert sample products
INSERT INTO Product (name, description, price, stock_quantity, category_id, sku) VALUES
('iPhone 13 Pro', 'Latest iPhone model with advanced features', 999.99, 50, 1, 'IPHONE-13-PRO'),
('Samsung Galaxy S21', 'Android smartphone with excellent camera', 799.99, 75, 1, 'SAMSUNG-S21'),
('Nike Air Max', 'Comfortable running shoes', 129.99, 100, 2, 'NIKE-AIR-MAX'),
('Adidas T-Shirt', 'Comfortable cotton t-shirt', 29.99, 200, 2, 'ADIDAS-TSHIRT'),
('Garden Hose', '50ft heavy-duty garden hose', 49.99, 30, 3, 'GARDEN-HOSE-50FT'),
('The Great Gatsby', 'Classic novel by F. Scott Fitzgerald', 12.99, 150, 4, 'BOOK-GATSBY'),
('Basketball', 'Official size basketball', 39.99, 80, 5, 'BASKETBALL-OFFICIAL');

-- Insert sample roles
INSERT INTO Role (name, description, permissions) VALUES
('Customer', 'Regular customer with basic permissions', '["view_products", "place_orders", "view_own_orders"]'),
('Store Manager', 'Store manager with product and order management', '["manage_products", "manage_orders", "view_reports", "manage_inventory"]'),
('System Administrator', 'Full system access', '["manage_users", "manage_roles", "system_config", "view_logs"]');

-- Insert sample person and user
INSERT INTO Person (first_name, last_name, email, phone) VALUES
('John', 'Doe', 'john.doe@example.com', '123-456-7890'),
('Jane', 'Smith', 'jane.smith@example.com', '098-765-4321'),
('Admin', 'User', 'admin@ecommerce.com', '555-123-4567');

INSERT INTO User (username, password_hash, person_id) VALUES
('johndoe', '$2b$10$hashedpassword1', 1),
('janesmith', '$2b$10$hashedpassword2', 2),
('admin', '$2b$10$hashedpassword3', 3);

-- Assign roles
INSERT INTO UserRole (user_id, role_id, assigned_by) VALUES
(1, 1, 3), -- John Doe as Customer
(2, 1, 3), -- Jane Smith as Customer
(3, 3, 3); -- Admin as System Administrator

-- =====================================================
-- VIEWS
-- =====================================================

-- Product catalog view
CREATE VIEW ProductCatalog AS
SELECT 
    p.id,
    p.name,
    p.description,
    p.price,
    p.currency,
    p.stock_quantity,
    p.image_url,
    p.sku,
    c.name as category_name,
    c.id as category_id,
    p.is_active,
    p.created_at
FROM Product p
JOIN Category c ON p.category_id = c.id
WHERE p.is_active = TRUE AND c.is_active = TRUE;

-- Order summary view
CREATE VIEW OrderSummary AS
SELECT 
    o.id,
    o.order_number,
    o.customer_id,
    CONCAT(p.first_name, ' ', p.last_name) as customer_name,
    o.total_amount,
    o.currency,
    o.status,
    o.created_at,
    COUNT(oi.id) as item_count
FROM Order o
JOIN User u ON o.customer_id = u.id
JOIN Person p ON u.person_id = p.id
LEFT JOIN OrderItem oi ON o.id = oi.order_id
GROUP BY o.id, o.order_number, o.customer_id, p.first_name, p.last_name, o.total_amount, o.currency, o.status, o.created_at;

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS VARCHAR(50) AS $$
DECLARE
    order_num VARCHAR(50);
    counter INTEGER;
BEGIN
    counter := 1;
    LOOP
        order_num := 'ORD-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(counter::TEXT, 4, '0');
        
        IF NOT EXISTS (SELECT 1 FROM Order WHERE order_number = order_num) THEN
            RETURN order_num;
        END IF;
        
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to generate invoice number
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS VARCHAR(50) AS $$
DECLARE
    invoice_num VARCHAR(50);
    counter INTEGER;
BEGIN
    counter := 1;
    LOOP
        invoice_num := 'INV-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(counter::TEXT, 4, '0');
        
        IF NOT EXISTS (SELECT 1 FROM Invoice WHERE invoice_number = invoice_num) THEN
            RETURN invoice_num;
        END IF;
        
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE Person IS 'Base entity for all users in the system';
COMMENT ON TABLE User IS 'Authentication and authorization information';
COMMENT ON TABLE Category IS 'Product categories for organization';
COMMENT ON TABLE Product IS 'Products available for purchase';
COMMENT ON TABLE Role IS 'User roles and permissions';
COMMENT ON TABLE UserRole IS 'Many-to-many relationship between users and roles';
COMMENT ON TABLE ShoppingCart IS 'Shopping cart for customers';
COMMENT ON TABLE CartItem IS 'Items in shopping cart';
COMMENT ON TABLE Order IS 'Customer orders';
COMMENT ON TABLE OrderItem IS 'Items in orders';
COMMENT ON TABLE Invoice IS 'Invoices for orders';
COMMENT ON TABLE Payment IS 'Payments for invoices';
COMMENT ON TABLE AuditLog IS 'Audit trail for data changes';

COMMENT ON COLUMN Product.price IS 'Product price in the specified currency';
COMMENT ON COLUMN Product.stock_quantity IS 'Available quantity in inventory';
COMMENT ON COLUMN Order.total_amount IS 'Total order amount including tax and shipping';
COMMENT ON COLUMN Order.status IS 'Current status of the order';
COMMENT ON COLUMN Payment.transaction_id IS 'External payment gateway transaction ID';

-- =====================================================
-- END OF SCHEMA
-- ===================================================== 