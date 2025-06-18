-- Crea la base de datos solo si no existe
CREATE DATABASE IF NOT EXISTS ecommerce_cart;
-- Selecciona la base de datos para trabajar
USE ecommerce_cart;

-- Tabla para almacenar categorías de productos
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    name VARCHAR(100) NOT NULL, -- Nombre de la categoría
    description TEXT, -- Descripción de la categoría
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de creación
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Fecha de última actualización
    deleted_at TIMESTAMP NULL DEFAULT NULL -- Fecha de borrado lógico (soft delete)
);

-- Tabla para productos
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    category_id INT NOT NULL, -- Llave foránea a categorías
    name VARCHAR(200) NOT NULL, -- Nombre del producto
    description TEXT, -- Descripción del producto
    price DECIMAL(10,2) NOT NULL, -- Precio del producto
    stock INT NOT NULL DEFAULT 0, -- Stock disponible
    image_url VARCHAR(255), -- URL de la imagen del producto
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de creación
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Fecha de última actualización
    deleted_at TIMESTAMP NULL DEFAULT NULL, -- Fecha de borrado lógico
    FOREIGN KEY (category_id) REFERENCES categories(category_id) -- Relación con categoría
);

-- Tabla para información de personas
CREATE TABLE people (
    person_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    first_name VARCHAR(100) NOT NULL, -- Nombre
    last_name VARCHAR(100) NOT NULL, -- Apellido
    email VARCHAR(100) NOT NULL UNIQUE, -- Correo electrónico único
    phone VARCHAR(20), -- Teléfono
    address TEXT, -- Dirección
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de creación
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Fecha de última actualización
    deleted_at TIMESTAMP NULL DEFAULT NULL -- Fecha de borrado lógico
);

-- Tabla para usuarios del sistema
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    person_id INT NOT NULL, -- Llave foránea a personas
    username VARCHAR(50) NOT NULL UNIQUE, -- Nombre de usuario único
    password VARCHAR(255) NOT NULL, -- Contraseña (hash)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de creación
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Fecha de última actualización
    last_login TIMESTAMP NULL DEFAULT NULL, -- Fecha de último inicio de sesión
    deleted_at TIMESTAMP NULL DEFAULT NULL, -- Fecha de borrado lógico
    FOREIGN KEY (person_id) REFERENCES people(person_id) -- Relación con persona
);

-- Tabla de roles de usuario
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    name VARCHAR(50) NOT NULL UNIQUE, -- Nombre del rol (único)
    description TEXT, -- Descripción del rol
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de creación
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Fecha de última actualización
);

-- Relación muchos a muchos entre usuarios y roles
CREATE TABLE user_roles (
    user_id INT NOT NULL, -- Llave foránea a usuario
    role_id INT NOT NULL, -- Llave foránea a rol
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de asignación
    PRIMARY KEY(user_id, role_id), -- Llave primaria compuesta
    FOREIGN KEY(user_id) REFERENCES users(user_id), -- Relación con usuario
    FOREIGN KEY(role_id) REFERENCES roles(role_id) -- Relación con rol
);

-- Tabla de tipos de usuario (cliente, empleado, proveedor, etc.)
CREATE TABLE user_types (
    user_type_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    name VARCHAR(30) NOT NULL UNIQUE -- Nombre del tipo de usuario (único)
);

-- Asignación de tipo a cada usuario
CREATE TABLE user_type_assignments (
    user_id INT PRIMARY KEY, -- Llave primaria (un usuario solo puede tener un tipo)
    user_type_id INT NOT NULL, -- Llave foránea a tipos
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de asignación
    FOREIGN KEY(user_id) REFERENCES users(user_id), -- Relación con usuario
    FOREIGN KEY(user_type_id) REFERENCES user_types(user_type_id) -- Relación con tipo
);

-- Información adicional para empleados
CREATE TABLE employees_extra (
    user_id INT PRIMARY KEY, -- Usuario empleado
    position VARCHAR(100), -- Puesto del empleado
    FOREIGN KEY(user_id) REFERENCES users(user_id) -- Relación con usuario
);

-- Información adicional para proveedores
CREATE TABLE suppliers_extra (
    user_id INT PRIMARY KEY, -- Usuario proveedor
    company_name VARCHAR(100), -- Nombre de la compañía
    FOREIGN KEY(user_id) REFERENCES users(user_id) -- Relación con usuario
);

-- Tabla para los posibles estados de una factura
CREATE TABLE invoice_status (
    status_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    status_name VARCHAR(20) NOT NULL UNIQUE -- Estado de la factura (pendiente, pagada, cancelada)
);

-- Tabla de facturas
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    user_id INT NOT NULL, -- Usuario (cliente) asociado
    invoice_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de la factura
    total DECIMAL(10,2) NOT NULL, -- Total de la factura
    status_id INT NOT NULL, -- Estado de la factura
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de creación
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Fecha de última actualización
    deleted_at TIMESTAMP NULL DEFAULT NULL, -- Fecha de borrado lógico
    FOREIGN KEY (user_id) REFERENCES users(user_id), -- Relación con usuario
    FOREIGN KEY (status_id) REFERENCES invoice_status(status_id) -- Relación con estado
);

-- Detalle de facturas (productos vendidos en cada factura)
CREATE TABLE invoice_details (
    invoice_detail_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    invoice_id INT NOT NULL, -- Llave foránea a factura
    product_id INT NOT NULL, -- Llave foránea a producto
    quantity INT NOT NULL, -- Cantidad vendida
    unit_price DECIMAL(10,2) NOT NULL, -- Precio unitario
    subtotal DECIMAL(10,2) NOT NULL, -- Subtotal (precio * cantidad)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de creación
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id), -- Relación con factura
    FOREIGN KEY (product_id) REFERENCES products(product_id) -- Relación con producto
);

-- Historial de precios de productos
CREATE TABLE product_price_history (
    price_history_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    product_id INT NOT NULL, -- Producto
    old_price DECIMAL(10,2) NOT NULL, -- Precio anterior
    new_price DECIMAL(10,2) NOT NULL, -- Precio nuevo
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha del cambio
    FOREIGN KEY (product_id) REFERENCES products(product_id) -- Relación con producto
);

-- Movimientos de stock de los productos
CREATE TABLE product_stock_movements (
    stock_movement_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    product_id INT NOT NULL, -- Producto involucrado
    change INT NOT NULL, -- Cantidad de cambio (positiva o negativa)
    reason VARCHAR(100) NOT NULL, -- Motivo (venta, devolución, reposición, etc.)
    reference_id INT, -- Referencia a factura u otra entidad
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha del movimiento
    FOREIGN KEY (product_id) REFERENCES products(product_id) -- Relación con producto
);

-- Registro de auditoría para trazabilidad
CREATE TABLE audit_log (
    audit_id INT PRIMARY KEY AUTO_INCREMENT, -- Llave primaria autoincremental
    table_name VARCHAR(50) NOT NULL, -- Tabla afectada
    record_id INT NOT NULL, -- Registro afectado
    action VARCHAR(20) NOT NULL, -- Acción realizada (INSERT, UPDATE, DELETE)
    performed_by INT, -- Usuario que realizó la acción
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de la acción
    details JSON, -- Detalles adicionales en formato JSON
    FOREIGN KEY (performed_by) REFERENCES users(user_id) -- Relación con usuario
);

-- Índices para optimización de búsquedas
CREATE INDEX idx_products_category_id ON products(category_id); -- Índice para búsquedas por categoría
CREATE INDEX idx_people_email ON people(email); -- Índice para email único
CREATE INDEX idx_users_username ON users(username); -- Índice para username único
CREATE INDEX idx_invoices_user_id ON invoices(user_id); -- Índice para facturas por usuario
CREATE INDEX idx_invoice_details_invoice_id ON invoice_details(invoice_id); -- Índice para detalles por factura
