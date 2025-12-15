# NestJS Documentation Specialist

## Instructions
When the `docbook` agent identifies a NestJS project (presence of `@nestjs/core`), use this skill.

### 1. Project Identity
- **Version**: NestJS major version.
- **Platform**: Express vs Fastify adapter (check `main.ts` factory options).
- **Mode**: Monolith vs Microservices (check `Transport` enum usage in `main.ts`).

### 2. Architecture Detection (Module Graph)
**CRITICAL**: NestJS is opinionated. Trace the Dependency Injection graph.
- **Root Module**: Start at `AppModule` (usually `app.module.ts`).
- **Module Tree**:
    - Identify Feature Modules (imports in `AppModule`).
    - Identify Global Modules (`@Global()` decorator).
- **Layer Analysis**:
    - **Controllers**: Handle HTTP/Message requests (`@Controller`, `@MessagePattern`).
    - **Providers/Services**: Business logic (`@Injectable`).
    - **Guards/Interceptors**: Cross-cutting concerns (`APP_GUARD`, `APP_INTERCEPTOR`).

### 3. Implementation Details
- **Entry Point**: `main.ts`. Check for `NestFactory.create`.
- **Configuration**: `@nestjs/config` usage. `ConfigService` injection.
- **Data Access**: TypeORM, Prisma, Mongoose? check module imports like `TypeOrmModule.forRoot`.
- **API Specs**: Swagger/OpenAPI setup (`DocumentBuilder` in `main.ts`).

### 4. Quality & Tooling
- **Testing**: NestJS generic `.spec.ts` files using `Test.createTestingModule`.
- **E2E**: `test/app.e2e-spec.ts`.
- **Linting**: Standard NestJS eslint config.

## Output Template Additions
**Technical Stack (NestJS)**:
- **Platform Adapter**: [Express/Fastify]
- **Database Strategy**: [TypeORM/Prisma + DB Name]
- **Architecture Style**: [Monolith/Microservice/Hybrid]

