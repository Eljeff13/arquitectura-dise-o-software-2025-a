--structured file with good architectural practices whith examples
-- Categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Clothing for all ages'),
('Home', 'Home goods and accessories');

-- Invoice status
INSERT INTO invoice_status (status_name) VALUES ('pending'), ('paid'), ('cancelled');

-- User types
INSERT INTO user_types (name) VALUES ('customer'), ('employee'), ('supplier');

-- People
INSERT INTO people (first_name, last_name, email, phone, address) VALUES
('John', 'Doe', 'john.doe@email.com', '555-1234', '123 Main St'),
('Jane', 'Smith', 'jane.smith@email.com', '555-5678', '456 Elm St'),
('Bob', 'Supplier', 'bob.supplier@email.com', '555-8765', '789 Oak St');

-- Users
INSERT INTO users (person_id, username, password) VALUES
(1, 'john_doe', 'hashed_password_1'),
(2, 'jane_smith', 'hashed_password_2'),
(3, 'bob_supplier', 'hashed_password_3');

-- User types assignments
INSERT INTO user_type_assignments (user_id, user_type_id) VALUES
(1, 1),
(2, 1),
(3, 3);

-- Employees extra (Jane is also an employee)
INSERT INTO employees_extra (user_id, position) VALUES
(2, 'Sales Manager');

-- Suppliers extra
INSERT INTO suppliers_extra (user_id, company_name) VALUES
(3, 'Best Supplies Inc.');

-- Roles
INSERT INTO roles (name, description) VALUES
('admin', 'System administrator'),
('customer', 'E-commerce customer'),
('supplier', 'Product supplier');

-- User roles
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 2),
(2, 1),
(2, 2),
(3, 3);

-- Products
INSERT INTO products (category_id, name, description, price, stock, image_url) VALUES
(1, 'Smartphone XYZ', 'Latest smartphone model', 599.99, 50, 'smartphone.jpg'),
(1, 'Laptop ABC', 'High-end laptop', 1299.99, 30, 'laptop.jpg'),
(2, 'Casual Shirt', 'Men casual shirt', 29.99, 100, 'shirt.jpg'),
(3, 'LED Lamp', 'Modern LED lamp', 49.99, 75, 'ledlamp.jpg');

-- Invoices
INSERT INTO invoices (user_id, total, status_id) VALUES
(1, 629.98, 2),
(2, 1299.99, 1);

-- Invoice details
INSERT INTO invoice_details (invoice_id, product_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 599.99, 599.99),
(1, 3, 1, 29.99, 29.99),
(2, 2, 1, 1299.99, 1299.99);
