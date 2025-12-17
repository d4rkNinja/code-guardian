# React Native Test Generation

## Overview
React Native testing with Jest and React Native Testing Library for component and navigation testing.

## Testing Tools

- **Jest**: Test runner (built-in)
- **@testing-library/react-native**: Component testing
- **Detox**: E2E testing

---

## Test Patterns

### **1. Component Testing**

```javascript
// UserProfile.test.js
import { render, fireEvent } from '@testing-library/react-native';
import UserProfile from './UserProfile';

describe('UserProfile', () => {
  it('renders user information', () => {
    const user = { name: 'John Doe', email: 'john@example.com' };

    const { getByText } = render(<UserProfile user={user} />);

    expect(getByText('John Doe')).toBeTruthy();
    expect(getByText('john@example.com')).toBeTruthy();
  });

  it('calls onEdit when button is pressed', () => {
    const onEdit = jest.fn();

    const { getByText } = render(
      <UserProfile user={mockUser} onEdit={onEdit} />
    );

    fireEvent.press(getByText('Edit'));

    expect(onEdit).toHaveBeenCalled();
  });
});
```

### **2. Mocking Native Modules**

```javascript
// __mocks__/@react-native-async-storage/async-storage.js
export default {
  setItem: jest.fn(),
  getItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
```

---

## References
- [React Native Testing Library](https://callstack.github.io/react-native-testing-library/)
- [Detox](https://wix.github.io/Detox/)
