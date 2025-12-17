# React Test Generation

## Overview
React testing focuses on component behavior, user interactions, and integration tests using React Testing Library and Vitest/Jest.

## Testing Tools

- **Vitest** or **Jest**: Test runners
- **React Testing Library**: Component testing
- **MSW (Mock Service Worker)**: API mocking
- **@testing-library/user-event**: User interaction simulation

---

## Test Patterns

### **1. Component Testing**

```javascript
// UserProfile.test.jsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserProfile } from './UserProfile';

describe('UserProfile Component', () => {
  it('should render user information', () => {
    const user = { name: 'John Doe', email: 'john@example.com' };

    render(<UserProfile user={user} />);

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('should handle edit button click', async () => {
    const handleEdit = vi.fn();
    const user = userEvent.setup();

    render(<UserProfile user={mockUser} onEdit={handleEdit} />);

    await user.click(screen.getByRole('button', { name: /edit/i }));

    expect(handleEdit).toHaveBeenCalledOnce();
  });
});
```

### **2. API Integration with MSW**

```javascript
// users.test.js
import { setupServer } from 'msw/node';
import { rest } from 'msw';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json([{ id: 1, name: 'Test User' }]));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it('fetches and displays users', async () => {
  render(<UserList />);

  await waitFor(() => {
    expect(screen.getByText('Test User')).toBeInTheDocument();
  });
});
```

---

## References
- [React Testing Library](https://testing-library.com/react)
- [Vitest](https://vitest.dev/)
- [MSW](https://mswjs.io/)
