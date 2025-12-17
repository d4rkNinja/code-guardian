# NestJS Test Generation

## Overview
NestJS testing with Jest for unit tests and E2E tests using Supertest.

## Testing Tools

- **Jest**: Default test runner
- **@nestjs/testing**: Testing utilities
- **Supertest**: HTTP assertions

---

## Test Patterns

### **1. Controller Testing**

```typescript
// users.controller.spec.ts
import { Test } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

describe('UsersController', () => {
  let controller: UsersController;
  let service: UsersService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: {
            create: jest.fn(),
            findAll: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);
  });

  it('should create user', async () => {
    const userDto = { email: 'test@example.com', username: 'test' };
    const expectedUser = { id: 1, ...userDto };

    jest.spyOn(service, 'create').mockResolvedValue(expectedUser);

    const result = await controller.create(userDto);

    expect(result).toEqual(expectedUser);
    expect(service.create).toHaveBeenCalledWith(userDto);
  });
});
```

### **2. E2E Testing**

```typescript
// test/users.e2e-spec.ts
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Users (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/users (POST)', () => {
    return request(app.getHttpServer())
      .post('/users')
      .send({ email: 'test@example.com', username: 'test' })
      .expect(201)
      .expect((res) => {
        expect(res.body.email).toEqual('test@example.com');
      });
  });

  afterAll(async () => {
    await app.close();
  });
});
```

---

## References
- [NestJS Testing](https://docs.nestjs.com/fundamentals/testing)
- [Jest](https://jestjs.io/)
