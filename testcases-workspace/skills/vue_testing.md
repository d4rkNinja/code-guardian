# Vue.js Test Generation

## Overview
Vue.js testing with Vitest and Vue Test Utils for component testing.

## Testing Tools

- **Vitest**: Modern test runner
- **@vue/test-utils**: Official Vue testing utility
- **MSW**: API mocking

---

## Test Patterns

```javascript
// UserProfile.spec.js
import { mount } from '@vue/test-utils';
import { describe, it, expect } from 'vitest';
import UserProfile from './UserProfile.vue';

describe('UserProfile', () => {
  it('renders user data', () => {
    const wrapper = mount(UserProfile, {
      props: {
        user: { name: 'John', email: 'john@example.com' }
      }
    });

    expect(wrapper.text()).toContain('John');
    expect(wrapper.text()).toContain('john@example.com');
  });

  it('emits edit event on button click', async () => {
    const wrapper = mount(UserProfile, {
      props: { user: mockUser }
    });

    await wrapper.find('button').trigger('click');

    expect(wrapper.emitted('edit')).toBeTruthy();
  });
});
```

---

## References
- [Vue Test Utils](https://test-utils.vuejs.org/)
- [Vitest](https://vitest.dev/)
