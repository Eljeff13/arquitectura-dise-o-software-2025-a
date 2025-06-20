# 📊 Data Dictionary - E-commerce Cart System

## 📋 Table of Contents
1. [Overview](#overview)
2. [Entity Relationship Model](#entity-relationship-model)
3. [Database Schema](#database-schema)
4. [Domain Entities](#domain-entities)
5. [Value Objects](#value-objects)
6. [Data Validation Rules](#data-validation-rules)
7. [Indexing Strategy](#indexing-strategy)
8. [Data Migration Plan](#data-migration-plan)

---

## 🎯 Overview

This data dictionary provides a comprehensive view of the data model for the E-commerce Cart System, ensuring consistency between the domain model, database schema, and business requirements. The design follows Domain-Driven Design principles with clear separation between entities, value objects, and their persistence representation.

### Design Principles
- **Single Source of Truth**: All data definitions are centralized and consistent
- **Domain Alignment**: Database schema reflects the domain model
- **Type Safety**: Strong typing with validation at all layers
- **Performance**: Optimized indexing and query patterns
- **Scalability**: Design supports future growth and changes

---

## 🏗️ Entity Relationship Model

### Core Domain Entities

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Person      │    │     Product     │    │    Category     │
│                 │    │                 │    │                 │
│ - id            │    │ - id            │    │ - id            │
│ - firstName     │    │ - name          │    │ - name          │
│ - lastName      │    │ - description   │    │ - description   │
│ - email         │    │ - price         │    │ - isActive      │
│ - phone         │    │ - stockQuantity │    │ - createdAt     │
│ - address       │    │ - imageUrl      │    │ - updatedAt     │
│ - createdAt     │    │ - categoryId    │    └─────────────────┘
│ - updatedAt     │    │ - createdAt     │              │
└─────────────────┘    │ - updatedAt     │              │
         │              └─────────────────┘              │
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       │
┌─────────────────┐    ┌─────────────────┐              │
│      User       │    │     Order       │              │
│                 │    │                 │              │
│ - id            │    │ - id            │              │
│ - username      │    │ - customerId    │              │
│ - passwordHash  │    │ - orderNumber   │              │
│ - isActive      │    │ - totalAmount   │              │
│ - lastLoginAt   │    │ - status        │              │
│ - personId      │    │ - createdAt     │              │
│ - createdAt     │    │ - updatedAt     │              │
│ - updatedAt     │    └─────────────────┘              │
└─────────────────┘              │                       │
         │                       │                       │
         │                       ▼                       │
         │              ┌─────────────────┐              │
         │              │   OrderItem     │              │
         │              │                 │              │
         │              │ - id            │              │
         │              │ - orderId       │              │
         │              │ - productId     │              │
         │              │ - quantity      │              │
         │              │ - unitPrice     │              │
         │              │ - subtotal      │              │
         │              │ - createdAt     │              │
         │              └─────────────────┘              │
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       │
┌─────────────────┐    ┌─────────────────┐              │
│      Role       │    │     Invoice     │              │
│                 │    │                 │              │
│ - id            │    │ - id            │              │
│ - name          │    │ - orderId       │              │
│ - description   │    │ - invoiceNumber │              │
│ - permissions   │    │ - amount        │              │
│ - isActive      │    │ - status        │              │
│ - createdAt     │    │ - dueDate       │              │
│ - updatedAt     │    │ - createdAt     │              │
└─────────────────┘    │ - updatedAt     │              │
         │              └─────────────────┘              │
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       │
┌─────────────────┐    ┌─────────────────┐              │
│   UserRole      │    │     Payment     │              │
│                 │    │                 │              │
│ - id            │    │ - id            │              │
│ - userId        │    │ - invoiceId     │              │
│ - roleId        │    │ - amount        │              │
│ - assignedAt    │    │ - method        │              │
│ - assignedBy    │    │ - status        │              │
│ - isActive      │    │ - transactionId │              │
│ - createdAt     │    │ - processedAt   │              │
│ - updatedAt     │    │ - createdAt     │              │
└─────────────────┘    │ - updatedAt     │              │
                       └─────────────────┘              │
                                                         │
                                                         │
                                                         ▼
                                                ┌─────────────────┐
                                                │   ShoppingCart  │
                                                │                 │
                                                │ - id            │
                                                │ - customerId    │
                                                │ - createdAt     │
                                                │ - updatedAt     │
                                                └─────────────────┘
                                                          │
                                                          ▼
                                                ┌─────────────────┐
                                                │  CartItem       │
                                                │                 │
                                                │ - id            │
                                                │ - cartId        │
                                                │ - productId     │
                                                │ - quantity      │
                                                │ - addedAt       │
                                                │ - updatedAt     │
                                                └─────────────────┘
```

### Relationship Types

1. **One-to-Many (1:N)**
   - Person → User (one person can have one user account)
   - Category → Product (one category can have many products)
   - User → Order (one user can have many orders)
   - Order → OrderItem (one order can have many items)
   - ShoppingCart → CartItem (one cart can have many items)

2. **Many-to-Many (M:N)**
   - User ↔ Role (through UserRole junction table)

3. **One-to-One (1:1)**
   - Order → Invoice (one order has one invoice)
   - Invoice → Payment (one invoice has one payment)

---

## 🗄️ Database Schema

### Core Tables

#### 1. Person Table
```sql
CREATE TABLE Person (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_created_at (createdAt)
);
```

**Business Rules:**
- Email must be unique across all persons
- Email format must be valid
- First name and last name are required
- Phone number is optional but must be valid format if provided

#### 2. User Table
```sql
CREATE TABLE User (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    passwordHash VARCHAR(255) NOT NULL,
    isActive BOOLEAN DEFAULT TRUE,
    lastLoginAt TIMESTAMP NULL,
    personId BIGINT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (personId) REFERENCES Person(id) ON DELETE CASCADE,
    INDEX idx_username (username),
    INDEX idx_person_id (personId),
    INDEX idx_is_active (isActive)
);
```

**Business Rules:**
- Username must be unique
- Password must be hashed using bcrypt
- User is active by default
- PersonId is required and must reference existing person

#### 3. Category Table
```sql
CREATE TABLE Category (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    isActive BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_is_active (isActive)
);
```

**Business Rules:**
- Category name must be unique
- Category is active by default
- Description is optional

#### 4. Product Table
```sql
CREATE TABLE Product (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stockQuantity INT NOT NULL DEFAULT 0,
    imageUrl VARCHAR(500),
    categoryId BIGINT NOT NULL,
    isActive BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (categoryId) REFERENCES Category(id),
    INDEX idx_category_id (categoryId),
    INDEX idx_name (name),
    INDEX idx_price (price),
    INDEX idx_stock_quantity (stockQuantity),
    INDEX idx_is_active (isActive),
    FULLTEXT idx_search (name, description)
);
```

**Business Rules:**
- Product name is required
- Price must be positive
- Stock quantity cannot be negative
- CategoryId is required and must reference existing category
- Product is active by default

#### 5. ShoppingCart Table
```sql
CREATE TABLE ShoppingCart (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customerId BIGINT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customerId) REFERENCES User(id) ON DELETE CASCADE,
    INDEX idx_customer_id (customerId),
    UNIQUE KEY uk_customer_cart (customerId)
);
```

**Business Rules:**
- Each customer can have only one active shopping cart
- Cart is automatically created when customer first adds item

#### 6. CartItem Table
```sql
CREATE TABLE CartItem (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cartId BIGINT NOT NULL,
    productId BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    addedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (cartId) REFERENCES ShoppingCart(id) ON DELETE CASCADE,
    FOREIGN KEY (productId) REFERENCES Product(id) ON DELETE CASCADE,
    INDEX idx_cart_id (cartId),
    INDEX idx_product_id (productId),
    UNIQUE KEY uk_cart_product (cartId, productId)
);
```

**Business Rules:**
- Quantity must be positive
- Each product can appear only once per cart
- CartItem is automatically removed when cart is converted to order

#### 7. Order Table
```sql
CREATE TABLE Order (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    orderNumber VARCHAR(50) NOT NULL UNIQUE,
    customerId BIGINT NOT NULL,
    totalAmount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customerId) REFERENCES User(id),
    INDEX idx_order_number (orderNumber),
    INDEX idx_customer_id (customerId),
    INDEX idx_status (status),
    INDEX idx_created_at (createdAt)
);
```

**Business Rules:**
- Order number must be unique and auto-generated
- Total amount must be positive
- Status follows predefined workflow
- CustomerId is required

#### 8. OrderItem Table
```sql
CREATE TABLE OrderItem (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    orderId BIGINT NOT NULL,
    productId BIGINT NOT NULL,
    quantity INT NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (orderId) REFERENCES Order(id) ON DELETE CASCADE,
    FOREIGN KEY (productId) REFERENCES Product(id),
    INDEX idx_order_id (orderId),
    INDEX idx_product_id (productId)
);
```

**Business Rules:**
- Quantity and unit price must be positive
- Subtotal = quantity × unit price
- Unit price is captured at time of order (price history)

#### 9. Invoice Table
```sql
CREATE TABLE Invoice (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    invoiceNumber VARCHAR(50) NOT NULL UNIQUE,
    orderId BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    dueDate DATE NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (orderId) REFERENCES Order(id),
    INDEX idx_invoice_number (invoiceNumber),
    INDEX idx_order_id (orderId),
    INDEX idx_status (status),
    INDEX idx_due_date (dueDate)
);
```

**Business Rules:**
- Invoice number must be unique and auto-generated
- Amount must match order total
- Due date is typically 30 days from creation
- Status follows payment workflow

#### 10. Payment Table
```sql
CREATE TABLE Payment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    invoiceId BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method ENUM('credit_card', 'paypal', 'bank_transfer', 'cash') NOT NULL,
    status ENUM('pending', 'processing', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transactionId VARCHAR(100),
    processedAt TIMESTAMP NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (invoiceId) REFERENCES Invoice(id),
    INDEX idx_invoice_id (invoiceId),
    INDEX idx_transaction_id (transactionId),
    INDEX idx_status (status),
    INDEX idx_method (method)
);
```

**Business Rules:**
- Amount must match invoice amount
- Transaction ID is required for completed payments
- Processed date is set when payment is completed

#### 11. Role Table
```sql
CREATE TABLE Role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSON NOT NULL,
    isActive BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_is_active (isActive)
);
```

**Business Rules:**
- Role name must be unique
- Permissions are stored as JSON for flexibility
- Role is active by default

#### 12. UserRole Table
```sql
CREATE TABLE UserRole (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    userId BIGINT NOT NULL,
    roleId BIGINT NOT NULL,
    assignedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assignedBy BIGINT,
    isActive BOOLEAN DEFAULT TRUE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE,
    FOREIGN KEY (roleId) REFERENCES Role(id) ON DELETE CASCADE,
    FOREIGN KEY (assignedBy) REFERENCES User(id),
    INDEX idx_user_id (userId),
    INDEX idx_role_id (roleId),
    INDEX idx_is_active (isActive),
    UNIQUE KEY uk_user_role (userId, roleId)
);
```

**Business Rules:**
- User can have multiple roles
- Same role cannot be assigned twice to same user
- Assignment is tracked with timestamp and assigner

---

## 🏛️ Domain Entities

### 1. Person Entity
```typescript
class Person {
  constructor(
    private readonly id: PersonId,
    private firstName: PersonName,
    private lastName: PersonName,
    private email: Email,
    private phone?: PhoneNumber,
    private address?: Address,
    private readonly createdAt: Date,
    private updatedAt: Date
  ) {}

  // Business methods
  updateContactInfo(email: Email, phone?: PhoneNumber): void {
    this.email = email;
    this.phone = phone;
    this.updatedAt = new Date();
  }

  updateAddress(address: Address): void {
    this.address = address;
    this.updatedAt = new Date();
  }

  getFullName(): string {
    return `${this.firstName.value} ${this.lastName.value}`;
  }
}
```

### 2. Product Entity
```typescript
class Product {
  constructor(
    private readonly id: ProductId,
    private name: ProductName,
    private description: ProductDescription,
    private price: Money,
    private stockQuantity: StockQuantity,
    private imageUrl?: ImageUrl,
    private category: Category,
    private isActive: boolean,
    private readonly createdAt: Date,
    private updatedAt: Date
  ) {}

  // Business methods
  updatePrice(newPrice: Money): void {
    if (newPrice.isNegative()) {
      throw new DomainError('Price cannot be negative');
    }
    this.price = newPrice;
    this.updatedAt = new Date();
  }

  updateStock(newQuantity: StockQuantity): void {
    if (newQuantity.isNegative()) {
      throw new DomainError('Stock quantity cannot be negative');
    }
    this.stockQuantity = newQuantity;
    this.updatedAt = new Date();
  }

  reserveStock(quantity: StockQuantity): void {
    if (this.stockQuantity.isLessThan(quantity)) {
      throw new DomainError('Insufficient stock');
    }
    this.stockQuantity = this.stockQuantity.subtract(quantity);
    this.updatedAt = new Date();
  }

  isAvailable(): boolean {
    return this.isActive && this.stockQuantity.isGreaterThan(StockQuantity.zero());
  }
}
```

### 3. Order Entity
```typescript
class Order {
  constructor(
    private readonly id: OrderId,
    private readonly orderNumber: OrderNumber,
    private customer: Customer,
    private items: OrderItem[],
    private totalAmount: Money,
    private status: OrderStatus,
    private readonly createdAt: Date,
    private updatedAt: Date
  ) {}

  // Business methods
  addItem(product: Product, quantity: Quantity): void {
    if (this.status !== OrderStatus.PENDING) {
      throw new DomainError('Cannot modify confirmed order');
    }

    const existingItem = this.items.find(item => item.productId.equals(product.id));
    if (existingItem) {
      existingItem.updateQuantity(existingItem.quantity.add(quantity));
    } else {
      const newItem = OrderItem.create(product, quantity);
      this.items.push(newItem);
    }

    this.recalculateTotal();
    this.updatedAt = new Date();
  }

  confirm(): void {
    if (this.status !== OrderStatus.PENDING) {
      throw new DomainError('Order can only be confirmed from pending status');
    }
    this.status = OrderStatus.CONFIRMED;
    this.updatedAt = new Date();
  }

  ship(): void {
    if (this.status !== OrderStatus.CONFIRMED) {
      throw new DomainError('Order can only be shipped from confirmed status');
    }
    this.status = OrderStatus.SHIPPED;
    this.updatedAt = new Date();
  }

  private recalculateTotal(): void {
    this.totalAmount = this.items.reduce(
      (total, item) => total.add(item.subtotal),
      Money.zero()
    );
  }
}
```

---

## 💎 Value Objects

### 1. Money Value Object
```typescript
class Money {
  constructor(private readonly amount: number, private readonly currency: Currency = Currency.USD) {
    if (amount < 0) {
      throw new DomainError('Money amount cannot be negative');
    }
  }

  add(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new DomainError('Cannot add money with different currencies');
    }
    return new Money(this.amount + other.amount, this.currency);
  }

  subtract(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new DomainError('Cannot subtract money with different currencies');
    }
    const result = this.amount - other.amount;
    if (result < 0) {
      throw new DomainError('Result cannot be negative');
    }
    return new Money(result, this.currency);
  }

  multiply(factor: number): Money {
    return new Money(this.amount * factor, this.currency);
  }

  static zero(currency: Currency = Currency.USD): Money {
    return new Money(0, currency);
  }

  get value(): number {
    return this.amount;
  }
}
```

### 2. Email Value Object
```typescript
class Email {
  constructor(private readonly value: string) {
    if (!this.isValid(value)) {
      throw new DomainError('Invalid email format');
    }
  }

  private isValid(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  get domain(): string {
    return this.value.split('@')[1];
  }

  toString(): string {
    return this.value;
  }
}
```

### 3. ProductName Value Object
```typescript
class ProductName {
  constructor(private readonly value: string) {
    if (value.trim().length < 3) {
      throw new DomainError('Product name must be at least 3 characters');
    }
    if (value.trim().length > 200) {
      throw new DomainError('Product name cannot exceed 200 characters');
    }
  }

  toString(): string {
    return this.value.trim();
  }
}
```

---

## ✅ Data Validation Rules

### 1. Input Validation
```typescript
// Product validation
const productValidationRules = {
  name: {
    required: true,
    minLength: 3,
    maxLength: 200,
    pattern: /^[a-zA-Z0-9\s\-_]+$/
  },
  price: {
    required: true,
    min: 0.01,
    max: 999999.99,
    precision: 2
  },
  stockQuantity: {
    required: true,
    min: 0,
    max: 999999
  },
  categoryId: {
    required: true,
    exists: 'Category'
  }
};

// User validation
const userValidationRules = {
  username: {
    required: true,
    minLength: 3,
    maxLength: 50,
    pattern: /^[a-zA-Z0-9_]+$/,
    unique: true
  },
  email: {
    required: true,
    format: 'email',
    unique: true
  },
  password: {
    required: true,
    minLength: 8,
    pattern: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/
  }
};
```

### 2. Business Rule Validation
```typescript
class OrderValidator {
  validateOrderCreation(cart: ShoppingCart, customer: Customer): ValidationResult {
    const errors: string[] = [];

    // Check if cart has items
    if (cart.items.length === 0) {
      errors.push('Cart cannot be empty');
    }

    // Check if customer is active
    if (!customer.isActive) {
      errors.push('Customer account is not active');
    }

    // Check product availability
    for (const item of cart.items) {
      if (!item.product.isAvailable()) {
        errors.push(`Product ${item.product.name} is not available`);
      }
      if (item.product.stockQuantity.isLessThan(item.quantity)) {
        errors.push(`Insufficient stock for product ${item.product.name}`);
      }
    }

    return new ValidationResult(errors.length === 0, errors);
  }
}
```

---

## 📈 Indexing Strategy

### 1. Primary Indexes
- All primary keys are automatically indexed
- Composite primary keys for junction tables

### 2. Secondary Indexes
```sql
-- Performance indexes
CREATE INDEX idx_product_category_price ON Product(categoryId, price);
CREATE INDEX idx_order_customer_status ON Order(customerId, status);
CREATE INDEX idx_order_created_at_status ON Order(createdAt, status);
CREATE INDEX idx_invoice_due_date_status ON Invoice(dueDate, status);

-- Search indexes
CREATE FULLTEXT INDEX idx_product_search ON Product(name, description);
CREATE INDEX idx_user_email_username ON User(email, username);

-- Foreign key indexes (automatically created)
-- All foreign key columns are indexed for join performance
```

### 3. Composite Indexes
```sql
-- Multi-column indexes for common query patterns
CREATE INDEX idx_order_customer_date ON Order(customerId, createdAt DESC);
CREATE INDEX idx_cartitem_cart_product ON CartItem(cartId, productId);
CREATE INDEX idx_userrole_user_active ON UserRole(userId, isActive);
```

---

## 🔄 Data Migration Plan

### Phase 1: Schema Creation
```sql
-- Create new tables with proper constraints
-- Migrate existing data with transformations
-- Update foreign key relationships
-- Add new indexes for performance
```

### Phase 2: Data Validation
```sql
-- Validate data integrity
-- Clean up orphaned records
-- Ensure referential integrity
-- Update statistics
```

### Phase 3: Application Migration
```sql
-- Update application code to use new schema
-- Deploy new version with feature flags
-- Monitor performance and data integrity
-- Rollback plan if issues arise
```

### Migration Scripts
```sql
-- Example migration script
BEGIN TRANSACTION;

-- Create new tables
CREATE TABLE IF NOT EXISTS Person (
    -- table definition
);

-- Migrate existing data
INSERT INTO Person (id, firstName, lastName, email, phone, address, createdAt, updatedAt)
SELECT 
    id,
    SUBSTRING_INDEX(name, ' ', 1) as firstName,
    SUBSTRING_INDEX(name, ' ', -1) as lastName,
    email,
    phone,
    address,
    created_at,
    updated_at
FROM old_customers_table;

-- Update foreign keys
ALTER TABLE User ADD CONSTRAINT fk_user_person 
    FOREIGN KEY (personId) REFERENCES Person(id);

COMMIT;
```

---

*This data dictionary serves as the authoritative source for all data-related decisions and should be maintained as the system evolves.* 