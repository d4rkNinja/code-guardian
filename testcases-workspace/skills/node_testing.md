# Node.js / JavaScript Test Generation

## Overview
Node.js applications require strategic test generation focusing on API endpoints, service integrations, and critical business workflows. This guide provides comprehensive patterns for generating high-quality tests using Jest, Vitest, and other modern testing frameworks.

## Testing Framework Selection

### **Jest** (Recommended for most projects)
- **Best for**: React, Node.js APIs, general JavaScript applications
- **Strengths**: Zero-config, built-in mocking, snapshot testing, code coverage
- **Version**: Use Jest 29+ for best performance

### **Vitest** (Recommended for Vite projects)
- **Best for**: Vite-based applications, modern frameworks (Svelte, Vue 3)
- **Strengths**: Fast execution, HMR in watch mode, Jest API compatibility
- **Version**: Use Vitest 3+ for latest features

### **Mocha + Chai** (Flexible alternative)
- **Best for**: Projects requiring high customization
- **Strengths**: Highly configurable, extensive plugin ecosystem
- **Use with**: Chai for assertions, Sinon for mocking

---

## Test Generation Patterns

### **1. API Endpoint Testing (Express/Fastify/NestJS)**

#### **What to Test:**
✅ **HTTP Methods**: GET, POST, PUT, PATCH, DELETE  
✅ **Status Codes**: 200, 201, 400, 401, 403, 404, 500  
✅ **Request Validation**: Body, query params, headers  
✅ **Response Format**: JSON structure, data types  
✅ **Authentication**: Token validation, protected routes  
✅ **Authorization**: Role-based access control  
✅ **Error Handling**: Invalid inputs, server errors  

#### **Example: Testing Express API with Jest + Supertest**
```javascript
// tests/integration/api/users.test.js
import request from 'supertest';
import app from '../../../src/app';
import { setupTestDB, clearTestDB } from '../../helpers/db';

describe('Users API', () => {
  beforeAll(async () => {
    await setupTestDB();
  });

  afterAll(async () => {
    await clearTestDB();
  });

  describe('POST /api/users', () => {
    it('should create a new user with valid data', async () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        username: 'testuser',
        password: 'SecurePass123!'
      };

      // Act
      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect('Content-Type', /json/)
        .expect(201);

      // Assert
      expect(response.body).toMatchObject({
        id: expect.any(String),
        email: userData.email,
        username: userData.username
      });
      expect(response.body.password).toBeUndefined(); // Should not return password
    });

    it('should reject user creation with invalid email', async () => {
      const invalidData = {
        email: 'invalid-email',
        username: 'testuser',
        password: 'SecurePass123!'
      };

      const response = await request(app)
        .post('/api/users')
        .send(invalidData)
        .expect(400);

      expect(response.body.error).toContain('Invalid email');
    });

    it('should reject duplicate email addresses', async () => {
      const userData = {
        email: 'duplicate@example.com',
        username: 'user1',
        password: 'Password123!'
      };

      // Create first user
      await request(app).post('/api/users').send(userData);

      // Attempt to create duplicate
      const response = await request(app)
        .post('/api/users')
        .send({ ...userData, username: 'user2' })
        .expect(409);

      expect(response.body.error).toContain('already exists');
    });

    it('should require authentication token for protected endpoint', async () => {
      await request(app)
        .get('/api/users/me')
        .expect(401);
    });

    it('should return user profile with valid token', async () => {
      const token = await createTestUserAndGetToken();

      const response = await request(app)
        .get('/api/users/me')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(response.body).toMatchObject({
        id: expect.any(String),
        email: expect.any(String)
      });
    });
  });

  describe('GET /api/users/:id', () => {
    it('should return user by ID', async () => {
      const user = await createTestUser();

      const response = await request(app)
        .get(`/api/users/${user.id}`)
        .expect(200);

      expect(response.body.id).toBe(user.id);
    });

    it('should return 404 for non-existent user', async () => {
      await request(app)
        .get('/api/users/nonexistent-id')
        .expect(404);
    });
  });
});
```

---

### **2. Service Layer Testing**

#### **What to Test:**
✅ **Business Logic**: Core workflows, data transformations  
✅ **Database Operations**: Create, read, update, delete  
✅ **External API Calls**: Integration with third-party services  
✅ **Error Handling**: Expected exceptions, rollback scenarios  
✅ **Transaction Management**: ACID properties, rollback on error  

#### **Example: Testing Service with Database Integration**
```javascript
// tests/integration/services/payment.test.js
import { PaymentService } from '../../../src/services/payment';
import { setupTestDB, clearTestDB } from '../../helpers/db';
import { createTestUser, createTestOrder } from '../../fixtures/factories';

describe('PaymentService', () => {
  let paymentService;
  let mockPaymentGateway;

  beforeAll(async () => {
    await setupTestDB();
  });

  afterAll(async () => {
    await clearTestDB();
  });

  beforeEach(() => {
    mockPaymentGateway = {
      charge: jest.fn().mockResolvedValue({
        success: true,
        transactionId: 'txn_123456'
      })
    };
    paymentService = new PaymentService(mockPaymentGateway);
  });

  describe('processPayment', () => {
    it('should successfully process valid payment', async () => {
      // Arrange
      const user = await createTestUser();
      const order = await createTestOrder({ userId: user.id });
      const paymentData = {
        orderId: order.id,
        amount: 99.99,
        currency: 'USD',
        cardToken: 'tok_valid_card'
      };

      // Act
      const result = await paymentService.processPayment(paymentData);

      // Assert
      expect(result).toMatchObject({
        success: true,
        transactionId: expect.any(String),
        orderId: order.id
      });
      expect(mockPaymentGateway.charge).toHaveBeenCalledWith({
        amount: 9999, // cents
        currency: 'USD',
        source: 'tok_valid_card',
        metadata: { orderId: order.id }
      });

      // Verify database state
      const updatedOrder = await Order.findById(order.id);
      expect(updatedOrder.status).toBe('paid');
      expect(updatedOrder.transactionId).toBe(result.transactionId);
    });

    it('should rollback order on payment failure', async () => {
      const order = await createTestOrder();
      mockPaymentGateway.charge.mockRejectedValue(
        new Error('Insufficient funds')
      );

      await expect(
        paymentService.processPayment({
          orderId: order.id,
          amount: 99.99,
          cardToken: 'tok_declined'
        })
      ).rejects.toThrow('Payment failed');

      // Verify order status unchanged
      const unchangedOrder = await Order.findById(order.id);
      expect(unchangedOrder.status).toBe('pending');
    });

    it('should handle network timeout errors gracefully', async () => {
      mockPaymentGateway.charge.mockRejectedValue(
        new Error('Request timeout')
      );

      const result = await paymentService.processPayment({
        orderId: 'order_123',
        amount: 50.00,
        cardToken: 'tok_card'
      });

      expect(result.success).toBe(false);
      expect(result.error).toContain('timeout');
    });
  });

  describe('refundPayment', () => {
    it('should successfully refund completed payment', async () => {
      const payment = await createCompletedPayment();

      mockPaymentGateway.refund = jest.fn().mockResolvedValue({
        success: true,
        refundId: 'ref_123'
      });

      const result = await paymentService.refundPayment(payment.id);

      expect(result.success).toBe(true);
      expect(mockPaymentGateway.refund).toHaveBeenCalledWith(
        payment.transactionId
      );
    });
  });
});
```

---

### **3. Main Function / Workflow Testing**

#### **What to Test:**
✅ **End-to-End Workflows**: Multi-step processes orchestrating multiple services  
✅ **State Transitions**: Order processing, user registration flows  
✅ **Side Effects**: Email sending, notifications, webhooks  
✅ **Idempotency**: Retry safety for critical operations  

#### **Example: Testing Complex Workflow**
```javascript
// tests/integration/workflows/order-fulfillment.test.js
import { OrderFulfillmentService } from '../../../src/workflows/order-fulfillment';
import { setupTestDB, clearTestDB } from '../../helpers/db';
import { 
  createTestOrder, 
  createTestProduct, 
  mockEmailService,
  mockInventoryService 
} from '../../fixtures';

describe('Order Fulfillment Workflow', () => {
  let fulfillmentService;
  let emailService;
  let inventoryService;

  beforeAll(async () => {
    await setupTestDB();
  });

  afterAll(async () => {
    await clearTestDB();
  });

  beforeEach(() => {
    emailService = mockEmailService();
    inventoryService = mockInventoryService();
    fulfillmentService = new OrderFulfillmentService({
      emailService,
      inventoryService
    });
  });

  it('should complete full order fulfillment workflow', async () => {
    // Arrange
    const product = await createTestProduct({ stock: 10 });
    const order = await createTestOrder({
      items: [{ productId: product.id, quantity: 2 }],
      status: 'paid'
    });

    // Act
    const result = await fulfillmentService.fulfillOrder(order.id);

    // Assert - Verify workflow completion
    expect(result.success).toBe(true);
    expect(result.trackingNumber).toBeTruthy();

    // Assert - Inventory updated
    expect(inventoryService.decrementStock).toHaveBeenCalledWith(
      product.id,
      2
    );

    // Assert - Emails sent
    expect(emailService.send).toHaveBeenCalledWith(
      expect.objectContaining({
        to: order.customerEmail,
        template: 'order_shipped',
        data: expect.objectContaining({
          trackingNumber: result.trackingNumber
        })
      })
    );

    // Assert - Database state
    const updatedOrder = await Order.findById(order.id);
    expect(updatedOrder.status).toBe('shipped');
    expect(updatedOrder.trackingNumber).toBe(result.trackingNumber);
  });

  it('should handle out-of-stock scenario', async () => {
    const product = await createTestProduct({ stock: 0 });
    const order = await createTestOrder({
      items: [{ productId: product.id, quantity: 1 }]
    });

    inventoryService.decrementStock.mockRejectedValue(
      new Error('Out of stock')
    );

    await expect(
      fulfillmentService.fulfillOrder(order.id)
    ).rejects.toThrow('Out of stock');

    // Verify no emails sent
    expect(emailService.send).not.toHaveBeenCalled();

    // Verify order status unchanged
    const unchangedOrder = await Order.findById(order.id);
    expect(unchangedOrder.status).not.toBe('shipped');
  });
});
```

---

## Testing Best Practices for Node.js

### **1. Database Testing**
```javascript
// Use test containers or in-memory databases
import { MongoMemoryServer } from 'mongodb-memory-server';

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  await mongoose.connect(mongoUri);
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

// OR use test containers for PostgreSQL
import { PostgreSqlContainer } from '@testcontainers/postgresql';

let pgContainer;

beforeAll(async () => {
  pgContainer = await new PostgreSqlContainer().start();
  process.env.DATABASE_URL = pgContainer.getConnectionUri();
});
```

### **2. Mocking External Services**
```javascript
// Mock HTTP requests
jest.mock('axios');
import axios from 'axios';

axios.get.mockResolvedValue({
  data: { id: 1, name: 'Test' }
});

// Mock environment variables
process.env.API_KEY = 'test-key';

// Mock date/time
jest.useFakeTimers();
jest.setSystemTime(new Date('2024-01-01'));
```

### **3. Test Data Factories**
```javascript
// tests/fixtures/factories.js
import { faker } from '@faker-js/faker';

export const createTestUser = async (overrides = {}) => {
  return await User.create({
    email: faker.internet.email(),
    username: faker.internet.userName(),
    password: await hashPassword('TestPass123!'),
    ...overrides
  });
};

export const createTestOrder = async (overrides = {}) => {
  const user = overrides.userId 
    ? await User.findById(overrides.userId)
    : await createTestUser();

  return await Order.create({
    userId: user.id,
    status: 'pending',
    total: 99.99,
    ...overrides
  });
};
```

---

## Framework-Specific Testing Rules

### **Jest Configuration**
```javascript
// jest.config.js
export default {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/config/**'
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 75,
      lines: 80,
      statements: 80
    }
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testTimeout: 10000
};
```

### **Vitest Configuration**
```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.js'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'tests/']
    },
    globalSetup: './tests/global-setup.js',
    setupFiles: './tests/setup.js'
  }
});
```

---

## Testing Checklist for Node.js APIs

- [ ] All API endpoints have integration tests
- [ ] Request validation tested (valid and invalid inputs)
- [ ] Authentication and authorization tested
- [ ] Error responses include proper status codes
- [ ] Database operations tested with real DB interactions
- [ ] External API calls are mocked appropriately
- [ ] Async operations handle errors correctly
- [ ] Environment variables are mocked in tests
- [ ] Tests are isolated and can run in parallel
- [ ] Test data is cleaned up after each test
- [ ] Code coverage meets minimum thresholds (70%+)
- [ ] CI/CD pipeline runs tests automatically

---

## Common Testing Patterns

### **Testing Async Functions**
```javascript
// Async/await (preferred)
it('should fetch user data', async () => {
  const data = await fetchUser(123);
  expect(data.id).toBe(123);
});

// Promises
it('should fetch user data', () => {
  return fetchUser(123).then(data => {
    expect(data.id).toBe(123);
  });
});

// Done callback (avoid unless necessary)
it('should fetch user data', (done) => {
  fetchUser(123, (err, data) => {
    expect(data.id).toBe(123);
    done();
  });
});
```

### **Testing Error Scenarios**
```javascript
it('should throw error for invalid ID', async () => {
  await expect(
    fetchUser('invalid-id')
  ).rejects.toThrow('Invalid user ID');
});

it('should handle network errors', async () => {
  mockAxios.get.mockRejectedValue(new Error('Network error'));
  
  await expect(
    fetchUserFromAPI(123)
  ).rejects.toThrow('Network error');
});
```

---

## References
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Vitest Documentation](https://vitest.dev/guide/)
- [Supertest for API Testing](https://github.com/visionmedia/supertest)
- [Node.js Testing Best Practices](https://github.com/goldbergyoni/nodebestpractices#5-testing-best-practices)
- [Test Containers for Node.js](https://node.testcontainers.org/)
