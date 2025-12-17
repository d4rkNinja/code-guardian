# Next.js Test Generation

## Overview
Next.js testing covers API routes, page components, and server-side rendering.

## Testing Tools

- **Vitest** or **Jest**: Test runners
- **@testing-library/react**: Component testing
- **Playwright** or **Cypress**: E2E testing

---

## Test Patterns

### **1. API Route Testing**

```javascript
// __tests__/api/users.test.js
import { createMocks } from 'node-mocks-http';
import handler from '@/pages/api/users';

describe('/api/users', () => {
  it('returns users list', async () => {
    const { req, res } = createMocks({
      method: 'GET',
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    expect(JSON.parse(res._getData())).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ id: expect.any(Number) })
      ])
    );
  });

  it('creates user with POST', async () => {
    const { req, res } = createMocks({
      method: 'POST',
      body: { email: 'test@example.com', username: 'test' },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(201);
  });
});
```

### **2. Page Component Testing**

```javascript
// __tests__/pages/users.test.jsx
import { render, screen } from '@testing-library/react';
import UsersPage from '@/pages/users';

it('renders users page', () => {
  const users = [{ id: 1, name: 'Test User' }];

  render(<UsersPage users={users} />);

  expect(screen.getByText('Test User')).toBeInTheDocument();
});
```

---

## References
- [Next.js Testing](https://nextjs.org/docs/testing)
- [Playwright](https://playwright.dev/)
