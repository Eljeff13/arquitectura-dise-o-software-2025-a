# 🎯 Patterns and Principles - E-commerce Cart System

## 📋 Table of Contents
1. [Domain-Driven Design (DDD)](#domain-driven-design-ddd)
2. [SOLID Principles](#solid-principles)
3. [Clean Architecture](#clean-architecture)
4. [Design Patterns](#design-patterns)
5. [Architectural Patterns](#architectural-patterns)
6. [Implementation Guidelines](#implementation-guidelines)

---

## 🏛️ Domain-Driven Design (DDD)

### Why DDD?

Domain-Driven Design is chosen as the foundational approach for this e-commerce system because:

1. **Complex Business Logic**: E-commerce involves intricate business rules around pricing, inventory, orders, and payments
2. **Business-Technology Alignment**: Ensures the software model reflects the actual business domain
3. **Team Collaboration**: Provides a common language between business stakeholders and developers
4. **Maintainability**: Creates a clear structure that evolves with business requirements

### Core DDD Concepts Applied

#### 1. Bounded Contexts
We define clear boundaries for different parts of the business:

- **Product Context**: Product catalog, categories, inventory management
- **User Context**: User profiles, authentication, preferences
- **Order Context**: Shopping cart, order processing, fulfillment
- **Financial Context**: Billing, payments, invoicing

#### 2. Ubiquitous Language
Establish a common vocabulary across the entire project:

```typescript
// Instead of generic terms, use domain-specific language
interface ShoppingCart {
  addItem(product: Product, quantity: Quantity): void;
  removeItem(itemId: CartItemId): void;
  calculateTotal(): Money;
  checkout(): Order;
}

interface Order {
  readonly orderId: OrderId;
  readonly customerId: CustomerId;
  readonly items: OrderItem[];
  readonly totalAmount: Money;
  readonly status: OrderStatus;
  
  confirm(): void;
  cancel(): void;
  ship(): void;
}
```

#### 3. Rich Domain Models
Encapsulate business logic within domain entities:

```typescript
class Product {
  private constructor(
    private readonly id: ProductId,
    private name: ProductName,
    private price: Money,
    private stock: StockQuantity,
    private category: Category
  ) {}

  static create(name: ProductName, price: Money, category: Category): Product {
    return new Product(
      ProductId.generate(),
      name,
      price,
      StockQuantity.zero(),
      category
    );
  }

  updateStock(newQuantity: StockQuantity): void {
    if (newQuantity.isNegative()) {
      throw new DomainError('Stock quantity cannot be negative');
    }
    this.stock = newQuantity;
  }

  isAvailable(): boolean {
    return this.stock.isGreaterThan(StockQuantity.zero());
  }

  reserveQuantity(quantity: StockQuantity): void {
    if (!this.isAvailable()) {
      throw new DomainError('Product is not available');
    }
    if (this.stock.isLessThan(quantity)) {
      throw new DomainError('Insufficient stock');
    }
    this.stock = this.stock.subtract(quantity);
  }
}
```

#### 4. Domain Services
Handle complex business operations that don't belong to a single entity:

```typescript
class OrderService {
  constructor(
    private orderRepository: OrderRepository,
    private productRepository: ProductRepository,
    private paymentService: PaymentService
  ) {}

  async createOrder(cart: ShoppingCart, customer: Customer): Promise<Order> {
    // Validate cart items availability
    for (const item of cart.items) {
      const product = await this.productRepository.findById(item.productId);
      if (!product.isAvailable()) {
        throw new DomainError(`Product ${product.name} is not available`);
      }
    }

    // Create order
    const order = Order.create(cart, customer);
    
    // Reserve inventory
    for (const item of order.items) {
      const product = await this.productRepository.findById(item.productId);
      product.reserveQuantity(item.quantity);
      await this.productRepository.save(product);
    }

    // Save order
    await this.orderRepository.save(order);
    
    return order;
  }
}
```

---

## 🔧 SOLID Principles

### 1. Single Responsibility Principle (SRP)

Each class has one reason to change:

```typescript
// ❌ Violates SRP
class OrderManager {
  saveOrder(order: Order): void { /* ... */ }
  sendEmailNotification(order: Order): void { /* ... */ }
  updateInventory(order: Order): void { /* ... */ }
  processPayment(order: Order): void { /* ... */ }
}

// ✅ Follows SRP
class OrderRepository {
  save(order: Order): Promise<void> { /* ... */ }
  findById(id: OrderId): Promise<Order> { /* ... */ }
}

class NotificationService {
  sendOrderConfirmation(order: Order): Promise<void> { /* ... */ }
}

class InventoryService {
  updateStock(order: Order): Promise<void> { /* ... */ }
}

class PaymentService {
  processPayment(order: Order): Promise<PaymentResult> { /* ... */ }
}
```

### 2. Open/Closed Principle (OCP)

Open for extension, closed for modification:

```typescript
// ✅ Extensible payment processing
interface PaymentProcessor {
  process(payment: Payment): Promise<PaymentResult>;
}

class CreditCardProcessor implements PaymentProcessor {
  async process(payment: Payment): Promise<PaymentResult> {
    // Credit card specific logic
  }
}

class PayPalProcessor implements PaymentProcessor {
  async process(payment: Payment): Promise<PaymentResult> {
    // PayPal specific logic
  }
}

class PaymentService {
  constructor(private processors: Map<PaymentMethod, PaymentProcessor>) {}

  async processPayment(payment: Payment): Promise<PaymentResult> {
    const processor = this.processors.get(payment.method);
    if (!processor) {
      throw new Error(`Unsupported payment method: ${payment.method}`);
    }
    return processor.process(payment);
  }
}
```

### 3. Liskov Substitution Principle (LSP)

Subtypes are substitutable for their base types:

```typescript
// ✅ Proper inheritance hierarchy
abstract class User {
  abstract canAccess(resource: Resource): boolean;
}

class Customer extends User {
  canAccess(resource: Resource): boolean {
    return resource.isPublic() || resource.ownerId === this.id;
  }
}

class Employee extends User {
  canAccess(resource: Resource): boolean {
    return true; // Employees have full access
  }
}

// Usage works with any User subtype
function checkAccess(user: User, resource: Resource): boolean {
  return user.canAccess(resource);
}
```

### 4. Interface Segregation Principle (ISP)

Clients shouldn't depend on interfaces they don't use:

```typescript
// ❌ Fat interface
interface UserOperations {
  createUser(user: User): Promise<void>;
  updateUser(user: User): Promise<void>;
  deleteUser(id: UserId): Promise<void>;
  getUser(id: UserId): Promise<User>;
  getAllUsers(): Promise<User[]>;
  authenticateUser(credentials: Credentials): Promise<AuthResult>;
}

// ✅ Segregated interfaces
interface UserRepository {
  save(user: User): Promise<void>;
  findById(id: UserId): Promise<User>;
  findAll(): Promise<User[]>;
  delete(id: UserId): Promise<void>;
}

interface UserAuthentication {
  authenticate(credentials: Credentials): Promise<AuthResult>;
}
```

### 5. Dependency Inversion Principle (DIP)

Depend on abstractions, not concretions:

```typescript
// ✅ Dependency injection with interfaces
class OrderService {
  constructor(
    private orderRepository: IOrderRepository,
    private paymentProcessor: IPaymentProcessor,
    private notificationService: INotificationService
  ) {}

  async processOrder(order: Order): Promise<void> {
    await this.orderRepository.save(order);
    await this.paymentProcessor.process(order.payment);
    await this.notificationService.sendConfirmation(order);
  }
}

// Implementation can be swapped without changing the service
const orderService = new OrderService(
  new PostgresOrderRepository(),
  new StripePaymentProcessor(),
  new EmailNotificationService()
);
```

---

## 🏗️ Clean Architecture

### Layer Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    Interface Layer                          │
│  Controllers, Presenters, Gateways, External Interfaces    │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                   Application Layer                         │
│  Use Cases, Application Services, Command/Query Handlers   │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  Entities, Value Objects, Domain Services, Business Rules  │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                       │
│  Repositories, External Services, Frameworks, Databases    │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Example

```typescript
// Domain Layer (innermost)
class Product {
  constructor(
    private readonly id: ProductId,
    private name: ProductName,
    private price: Money
  ) {}

  updatePrice(newPrice: Money): void {
    if (newPrice.isNegative()) {
      throw new DomainError('Price cannot be negative');
    }
    this.price = newPrice;
  }
}

// Application Layer
class UpdateProductPriceUseCase {
  constructor(private productRepository: IProductRepository) {}

  async execute(command: UpdateProductPriceCommand): Promise<void> {
    const product = await this.productRepository.findById(command.productId);
    product.updatePrice(command.newPrice);
    await this.productRepository.save(product);
  }
}

// Interface Layer
class ProductController {
  constructor(private updateProductPriceUseCase: UpdateProductPriceUseCase) {}

  async updatePrice(req: Request, res: Response): Promise<void> {
    const command = new UpdateProductPriceCommand(
      req.params.id,
      req.body.price
    );
    await this.updateProductPriceUseCase.execute(command);
    res.status(200).json({ message: 'Price updated successfully' });
  }
}

// Infrastructure Layer
class PostgresProductRepository implements IProductRepository {
  async findById(id: ProductId): Promise<Product> {
    // Database implementation
  }

  async save(product: Product): Promise<void> {
    // Database implementation
  }
}
```

---

## 🎨 Design Patterns

### 1. Repository Pattern

Abstracts data access logic:

```typescript
interface IProductRepository {
  findById(id: ProductId): Promise<Product>;
  findByCategory(category: Category): Promise<Product[]>;
  save(product: Product): Promise<void>;
  delete(id: ProductId): Promise<void>;
}

class PostgresProductRepository implements IProductRepository {
  constructor(private connection: DatabaseConnection) {}

  async findById(id: ProductId): Promise<Product> {
    const result = await this.connection.query(
      'SELECT * FROM products WHERE id = $1',
      [id.value]
    );
    return this.mapToProduct(result.rows[0]);
  }

  async save(product: Product): Promise<void> {
    await this.connection.query(
      'INSERT INTO products (id, name, price) VALUES ($1, $2, $3) ON CONFLICT (id) DO UPDATE SET name = $2, price = $3',
      [product.id.value, product.name.value, product.price.value]
    );
  }
}
```

### 2. Factory Pattern

Creates objects without specifying their exact classes:

```typescript
class ProductFactory {
  static createElectronics(name: string, price: number): Product {
    return new Product(
      ProductId.generate(),
      new ProductName(name),
      new Money(price),
      Category.ELECTRONICS
    );
  }

  static createClothing(name: string, price: number): Product {
    return new Product(
      ProductId.generate(),
      new ProductName(name),
      new Money(price),
      Category.CLOTHING
    );
  }
}
```

### 3. Strategy Pattern

Defines a family of algorithms and makes them interchangeable:

```typescript
interface PricingStrategy {
  calculatePrice(product: Product, quantity: number): Money;
}

class RegularPricingStrategy implements PricingStrategy {
  calculatePrice(product: Product, quantity: number): Money {
    return product.price.multiply(quantity);
  }
}

class BulkPricingStrategy implements PricingStrategy {
  calculatePrice(product: Product, quantity: number): Money {
    if (quantity >= 10) {
      return product.price.multiply(quantity).multiply(0.9); // 10% discount
    }
    return product.price.multiply(quantity);
  }
}

class PricingService {
  constructor(private strategy: PricingStrategy) {}

  calculateTotal(items: CartItem[]): Money {
    return items.reduce((total, item) => {
      return total.add(this.strategy.calculatePrice(item.product, item.quantity));
    }, Money.zero());
  }
}
```

### 4. Observer Pattern

Defines a one-to-many dependency between objects:

```typescript
interface OrderObserver {
  onOrderCreated(order: Order): void;
  onOrderStatusChanged(order: Order, newStatus: OrderStatus): void;
}

class OrderService {
  private observers: OrderObserver[] = [];

  addObserver(observer: OrderObserver): void {
    this.observers.push(observer);
  }

  async createOrder(cart: ShoppingCart): Promise<Order> {
    const order = Order.create(cart);
    await this.orderRepository.save(order);
    
    // Notify observers
    this.observers.forEach(observer => observer.onOrderCreated(order));
    
    return order;
  }
}

class InventoryObserver implements OrderObserver {
  onOrderCreated(order: Order): void {
    // Update inventory levels
  }
}

class NotificationObserver implements OrderObserver {
  onOrderCreated(order: Order): void {
    // Send confirmation email
  }
}
```

---

## 🏛️ Architectural Patterns

### 1. CQRS (Command Query Responsibility Segregation)

Separates read and write operations:

```typescript
// Commands (Write operations)
class CreateOrderCommand {
  constructor(
    public readonly customerId: CustomerId,
    public readonly items: OrderItem[]
  ) {}
}

class CreateOrderHandler {
  constructor(private orderRepository: IOrderRepository) {}

  async handle(command: CreateOrderCommand): Promise<OrderId> {
    const order = Order.create(command.customerId, command.items);
    await this.orderRepository.save(order);
    return order.id;
  }
}

// Queries (Read operations)
class GetOrderQuery {
  constructor(public readonly orderId: OrderId) {}
}

class GetOrderHandler {
  constructor(private orderQueryService: IOrderQueryService) {}

  async handle(query: GetOrderQuery): Promise<OrderDto> {
    return this.orderQueryService.findById(query.orderId);
  }
}
```

### 2. Event Sourcing

Stores all changes as a sequence of events:

```typescript
interface DomainEvent {
  readonly eventId: EventId;
  readonly aggregateId: AggregateId;
  readonly occurredOn: Date;
  readonly eventType: string;
}

class OrderCreatedEvent implements DomainEvent {
  constructor(
    public readonly eventId: EventId,
    public readonly aggregateId: OrderId,
    public readonly occurredOn: Date,
    public readonly customerId: CustomerId,
    public readonly items: OrderItem[]
  ) {}
}

class OrderRepository {
  async save(order: Order): Promise<void> {
    const events = order.getUncommittedEvents();
    await this.eventStore.appendEvents(order.id, events);
    order.markEventsAsCommitted();
  }

  async findById(id: OrderId): Promise<Order> {
    const events = await this.eventStore.getEvents(id);
    return Order.reconstruct(events);
  }
}
```

### 3. Saga Pattern

Manages distributed transactions:

```typescript
class OrderSaga {
  constructor(
    private orderService: OrderService,
    private paymentService: PaymentService,
    private inventoryService: InventoryService
  ) {}

  async execute(order: Order): Promise<void> {
    try {
      // Step 1: Reserve inventory
      await this.inventoryService.reserveItems(order.items);
      
      // Step 2: Process payment
      await this.paymentService.processPayment(order.payment);
      
      // Step 3: Confirm order
      await this.orderService.confirmOrder(order.id);
      
    } catch (error) {
      // Compensating actions
      await this.compensate(order, error);
    }
  }

  private async compensate(order: Order, error: Error): Promise<void> {
    // Rollback inventory reservation
    await this.inventoryService.releaseItems(order.items);
    
    // Cancel order
    await this.orderService.cancelOrder(order.id);
  }
}
```

---

## 📋 Implementation Guidelines

### 1. Code Organization

```
src/
├── domain/
│   ├── entities/           # Domain entities
│   ├── value-objects/      # Value objects
│   ├── services/           # Domain services
│   └── events/             # Domain events
├── application/
│   ├── commands/           # Command handlers
│   ├── queries/            # Query handlers
│   ├── services/           # Application services
│   └── dtos/               # Data transfer objects
├── infrastructure/
│   ├── persistence/        # Repository implementations
│   ├── external/           # External service adapters
│   ├── messaging/          # Message brokers
│   └── security/           # Authentication/authorization
└── interfaces/
    ├── rest/               # REST API controllers
    ├── graphql/            # GraphQL resolvers
    └── web/                # Web interface
```

### 2. Naming Conventions

- **Entities**: PascalCase (e.g., `Product`, `Order`)
- **Value Objects**: PascalCase (e.g., `ProductId`, `Money`)
- **Services**: PascalCase with "Service" suffix (e.g., `OrderService`)
- **Repositories**: PascalCase with "Repository" suffix (e.g., `ProductRepository`)
- **Interfaces**: PascalCase with "I" prefix (e.g., `IProductRepository`)

### 3. Error Handling

```typescript
// Domain-specific errors
class DomainError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'DomainError';
  }
}

class ProductNotFoundError extends DomainError {
  constructor(productId: ProductId) {
    super(`Product with id ${productId.value} not found`);
    this.name = 'ProductNotFoundError';
  }
}

// Application error handling
class ApplicationService {
  async execute(command: Command): Promise<Result> {
    try {
      // Business logic
      return Result.success(data);
    } catch (error) {
      if (error instanceof DomainError) {
        return Result.failure(error.message);
      }
      return Result.failure('An unexpected error occurred');
    }
  }
}
```

### 4. Testing Strategy

```typescript
// Unit tests for domain logic
describe('Product', () => {
  it('should not allow negative price', () => {
    expect(() => {
      new Product(
        ProductId.generate(),
        new ProductName('Test Product'),
        new Money(-10)
      );
    }).toThrow(DomainError);
  });
});

// Integration tests for use cases
describe('CreateOrderUseCase', () => {
  it('should create order successfully', async () => {
    const useCase = new CreateOrderUseCase(mockRepository);
    const result = await useCase.execute(command);
    expect(result.isSuccess()).toBe(true);
  });
});
```

---

*These patterns and principles provide a solid foundation for building a maintainable, scalable, and testable e-commerce system. They should be applied consistently throughout the development process.* 